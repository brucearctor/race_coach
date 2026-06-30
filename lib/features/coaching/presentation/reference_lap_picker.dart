import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/coaching/data/reference_lap_service.dart';
import 'package:race_coach/features/session/data/session_storage.dart';
import 'package:race_coach/features/track/data/track_service.dart';

// =============================================================================
// ReferenceLapPicker — bottom sheet for selecting a reference lap
// =============================================================================

/// Shows a bottom sheet listing saved sessions and laps for the current track.
///
/// The user can pick any completed lap to use as a reference for delta-T
/// coaching, or clear the current selection.
Future<void> showReferenceLapPicker(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _ReferenceLapPickerSheet(),
  );
}

class _ReferenceLapPickerSheet extends ConsumerStatefulWidget {
  const _ReferenceLapPickerSheet();

  @override
  ConsumerState<_ReferenceLapPickerSheet> createState() =>
      _ReferenceLapPickerSheetState();
}

class _ReferenceLapPickerSheetState
    extends ConsumerState<_ReferenceLapPickerSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final refState = ref.watch(referenceLapServiceProvider);
    final trackState = ref.watch(trackServiceProvider);
    final currentTrack = trackState.selectedTrack?.name ?? '';
    final sessionList = ref.watch(sessionListProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title + current selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reference Lap',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (refState.isLoaded)
                          Text(
                            'Current: ${refState.formattedLapTime}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                  if (refState.isLoaded)
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final trackName =
                                  '${trackState.selectedTrack?.name ?? ''} '
                                          '${trackState.selectedConfig?.name ?? ''}'
                                      .trim();
                              await ref
                                  .read(referenceLapServiceProvider.notifier)
                                  .clear(trackName: trackName);
                            },
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),

            if (_isLoading) const LinearProgressIndicator(),

            const Divider(height: 1),

            // Session list
            Expanded(
              child: sessionList.when(
                data: (sessions) {
                  // Filter to current track.
                  final trackSessions = sessions
                      .where((s) =>
                          currentTrack.isEmpty ||
                          s.trackName
                              .toLowerCase()
                              .contains(currentTrack.toLowerCase()))
                      .toList();

                  if (trackSessions.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No saved sessions for this track.\n\n'
                          'Complete a session to create a reference lap.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: trackSessions.length,
                    itemBuilder: (context, index) {
                      return _SessionTile(
                        session: trackSessions[index],
                        isCurrentRef: refState.sessionId ==
                            trackSessions[index].sessionId,
                        currentRefLap: refState.lapNumber,
                        onLapSelected: (sessionId, lapNumber) =>
                            _onLapSelected(sessionId, lapNumber),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onLapSelected(String sessionId, int lapNumber) async {
    setState(() => _isLoading = true);

    final loaded = await ref
        .read(referenceLapServiceProvider.notifier)
        .loadFromSession(sessionId: sessionId, lapNumber: lapNumber);

    if (mounted) {
      setState(() => _isLoading = false);
      if (loaded) {
        Navigator.of(context).pop();
      } else {
        // Surface the error to the user.
        final error =
            ref.read(referenceLapServiceProvider).error ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load lap: $error')),
        );
      }
    }
  }
}

// =============================================================================
// Session tile — expandable list of laps within a session
// =============================================================================

class _SessionTile extends ConsumerStatefulWidget {
  const _SessionTile({
    required this.session,
    required this.isCurrentRef,
    required this.currentRefLap,
    required this.onLapSelected,
  });

  final SessionSummary session;
  final bool isCurrentRef;
  final int? currentRefLap;
  final void Function(String sessionId, int lapNumber) onLapSelected;

  @override
  ConsumerState<_SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends ConsumerState<_SessionTile> {
  bool _expanded = false;
  List<_LapInfo>? _laps;
  bool _loadingLaps = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final dateStr =
        '${s.date.month}/${s.date.day}/${s.date.year}';
    final bestStr = s.bestLap != null
        ? _formatDuration(s.bestLap!)
        : 'No completed laps';

    return Column(
      children: [
        ListTile(
          title: Text(s.trackName),
          subtitle: Text('$dateStr · ${s.lapCount} laps · Best: $bestStr'),
          trailing: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () {
            setState(() => _expanded = !_expanded);
            if (_expanded && _laps == null) {
              _loadLaps();
            }
          },
        ),
        if (_expanded) ...[
          if (_loadingLaps)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else if (_laps != null)
            ..._laps!.map((lap) {
              final isCurrentRef = widget.isCurrentRef &&
                  widget.currentRefLap == lap.number;
              return ListTile(
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                leading: isCurrentRef
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.radio_button_unchecked),
                title: Text('Lap ${lap.number}'),
                subtitle: Text(lap.timeStr),
                onTap: () =>
                    widget.onLapSelected(s.sessionId, lap.number),
              );
            }),
        ],
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _loadLaps() async {
    setState(() => _loadingLaps = true);

    try {
      final storage = ref.read(sessionStorageProvider);
      final session = await storage.loadSession(widget.session.sessionId);
      final laps = session.laps
          .where((l) => l.lapTimeSeconds > 0)
          .map((l) => _LapInfo(
                number: l.lapNumber,
                timeStr: _formatLapTime(l.lapTimeSeconds),
                timeSeconds: l.lapTimeSeconds,
              ))
          .toList();
      laps.sort((a, b) => a.timeSeconds.compareTo(b.timeSeconds));

      if (mounted) {
        setState(() {
          _laps = laps;
          _loadingLaps = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _laps = [];
          _loadingLaps = false;
        });
      }
    }
  }
}

// =============================================================================
// Helpers
// =============================================================================

class _LapInfo {
  const _LapInfo({
    required this.number,
    required this.timeStr,
    required this.timeSeconds,
  });

  final int number;
  final String timeStr;
  final double timeSeconds;
}

/// Format milliseconds as a lap time string.
///
/// Handles the 60-second rollover edge case (e.g. 59999ms → "1:00.0"
/// instead of "0:60.0").
String _formatMs(int totalMs) {
  // Round to nearest 100ms for display.
  final roundedMs = ((totalMs / 100).round()) * 100;
  final minutes = roundedMs ~/ 60000;
  final seconds = (roundedMs % 60000) / 1000;
  if (minutes > 0) {
    return '$minutes:${seconds.toStringAsFixed(1).padLeft(4, '0')}';
  }
  return '${seconds.toStringAsFixed(1)}s';
}

String _formatDuration(Duration d) => _formatMs(d.inMilliseconds);

String _formatLapTime(double seconds) => _formatMs((seconds * 1000).round());
