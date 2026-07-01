import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:race_coach/core/router/app_router.dart';
import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/auth/data/auth_service.dart';
import 'package:race_coach/features/session/data/session_meta_storage.dart';
import 'package:race_coach/features/session/data/session_storage.dart';
import 'package:race_coach/features/session/data/session_uploader.dart';
import 'package:race_coach/features/session/presentation/session_meta_editor.dart';
import 'package:race_coach/generated/racecoach/v1/session.pb.dart';

// =============================================================================
// Sessions Screen — list, upload, and manage recorded sessions
// =============================================================================

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  /// Set of session IDs currently being uploaded.
  final _uploading = <String>{};

  /// Set of session IDs confirmed uploaded to cloud.
  final _uploaded = <String>{};

  /// Set of session IDs that failed to upload.
  final _failed = <String>{};

  @override
  void initState() {
    super.initState();
    // Check which sessions are already uploaded.
    _checkUploadedStatus();
  }

  Future<void> _checkUploadedStatus() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final sessions = ref.read(sessionListProvider).valueOrNull ?? [];
    final uploader = ref.read(sessionUploaderProvider);

    for (final session in sessions) {
      try {
        final uploaded = await uploader.isUploaded(session.sessionId);
        if (uploaded && mounted) {
          setState(() => _uploaded.add(session.sessionId));
        }
      } catch (_) {
        // Ignore check failures.
      }
    }
  }

  Future<void> _uploadSession(String sessionId) async {
    setState(() {
      _uploading.add(sessionId);
      _failed.remove(sessionId);
    });

    try {
      final uploader = ref.read(sessionUploaderProvider);
      await uploader.uploadSession(sessionId);

      if (mounted) {
        setState(() {
          _uploading.remove(sessionId);
          _uploaded.add(sessionId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session uploaded'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploading.remove(sessionId);
          _failed.add(sessionId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Session',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final storage = ref.read(sessionStorageProvider);
    await storage.deleteSession(sessionId);

    // Refresh the list.
    ref.invalidate(sessionListProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session deleted'),
          backgroundColor: AppColors.textSecondary,
        ),
      );
    }
  }

  Future<void> _openMetaEditor(SessionSummary session) async {
    // Load existing metadata (if any).
    final metaStorage = ref.read(sessionMetaStorageProvider);
    final existingMeta = await metaStorage.load(session.sessionId);

    if (!mounted) return;

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            SessionMetaEditor(sessionId: session.sessionId, meta: existingMeta),
      ),
    );

    if (saved == true && mounted) {
      // Refresh the list to pick up updated metadata.
      ref.invalidate(sessionListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionListProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Sessions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () => ref.invalidate(sessionListProvider),
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load sessions',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 64,
                    color: AppColors.textDim,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Sessions Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect a device and start driving',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final isUploading = _uploading.contains(session.sessionId);
              final isUploaded = _uploaded.contains(session.sessionId);
              final isFailed = _failed.contains(session.sessionId);

              return _SessionCard(
                session: session,
                isUploading: isUploading,
                isUploaded: isUploaded,
                isFailed: isFailed,
                isSignedIn: user != null,
                onUpload: () => _uploadSession(session.sessionId),
                onDelete: () => _deleteSession(session.sessionId),
                onEditMeta: () => _openMetaEditor(session),
              );
            },
          );
        },
      ),
    );
  }
}

// =============================================================================
// Session Card
// =============================================================================

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.isUploading,
    required this.isUploaded,
    required this.isFailed,
    required this.isSignedIn,
    required this.onUpload,
    required this.onDelete,
    required this.onEditMeta,
  });

  final SessionSummary session;
  final bool isUploading;
  final bool isUploaded;
  final bool isFailed;
  final bool isSignedIn;
  final VoidCallback onUpload;
  final VoidCallback onDelete;
  final VoidCallback onEditMeta;

  @override
  Widget build(BuildContext context) {
    final hasMetadata =
        session.driverName != null || session.vehicleName != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEditMeta,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Track name + date ──────────────
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.trackName.isNotEmpty
                          ? session.trackName
                          : 'Unknown Track',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(session.date),
                    style: const TextStyle(
                      color: AppColors.textDim,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              // ── Metadata subtitle (driver / vehicle) ──
              if (hasMetadata) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SizedBox(width: 26), // align with track name
                    if (session.driverName != null) ...[
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.textDim,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session.driverName!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (session.driverName != null &&
                        session.vehicleName != null)
                      const SizedBox(width: 12),
                    if (session.vehicleName != null) ...[
                      Icon(
                        Icons.directions_car_outlined,
                        size: 14,
                        color: AppColors.textDim,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          session.vehicleName!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // ── "Add session details" for old sessions ─
              if (!hasMetadata) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SizedBox(width: 26),
                    Icon(
                      Icons.add_circle_outline,
                      size: 14,
                      color: AppColors.textDim,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Add session details',
                      style: TextStyle(
                        color: AppColors.textDim,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // ── Stats row ──────────────────────────────
              Row(
                children: [
                  _StatChip(
                    icon: Icons.flag,
                    label: '${session.lapCount} laps',
                  ),
                  const SizedBox(width: 16),
                  if (session.bestLap != null)
                    _StatChip(
                      icon: Icons.timer,
                      label: _formatDuration(session.bestLap!),
                      color: AppColors.success,
                    ),
                  if (session.sessionType != null) ...[
                    const SizedBox(width: 16),
                    _StatChip(
                      icon: Icons.sports_score,
                      label: _sessionTypeLabel(session.sessionType!),
                      color: AppColors.info,
                    ),
                  ],
                  const Spacer(),

                  // ── Upload button ──────────────────────
                  if (isUploading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  else if (isUploaded)
                    const Icon(
                      Icons.cloud_done,
                      color: AppColors.success,
                      size: 24,
                    )
                  else if (isFailed)
                    IconButton(
                      icon: const Icon(
                        Icons.cloud_off,
                        color: AppColors.error,
                        size: 24,
                      ),
                      tooltip: 'Retry upload',
                      onPressed: isSignedIn ? onUpload : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.cloud_upload_outlined,
                        color: isSignedIn
                            ? AppColors.primary
                            : AppColors.textDim,
                        size: 24,
                      ),
                      tooltip: isSignedIn
                          ? 'Upload to cloud'
                          : 'Sign in to upload',
                      onPressed: isSignedIn ? onUpload : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  const SizedBox(width: 8),

                  // ── Delete button ──────────────────────
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.textDim,
                      size: 22,
                    ),
                    tooltip: 'Delete session',
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    final tenths = (d.inMilliseconds % 1000) ~/ 100;
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}.$tenths';
    }
    return '$seconds.$tenths';
  }

  String _sessionTypeLabel(SessionType type) {
    switch (type) {
      case SessionType.SESSION_TYPE_PRACTICE:
        return 'Practice';
      case SessionType.SESSION_TYPE_QUALIFYING:
        return 'Qualifying';
      case SessionType.SESSION_TYPE_RACE:
        return 'Race';
      case SessionType.SESSION_TYPE_TEST:
        return 'Test';
      default:
        return '';
    }
  }
}

// =============================================================================
// Stat Chip
// =============================================================================

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    this.color = AppColors.textSecondary,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}
