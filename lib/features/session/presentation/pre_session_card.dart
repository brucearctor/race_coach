import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/session/data/session_defaults.dart';
import 'package:race_coach/generated/racecoach/v1/session.pb.dart';

// =============================================================================
// PreSessionCard — bottom sheet shown before starting a recording
// =============================================================================

/// Shows a bottom sheet that pre-populates from [SessionDefaults] and starts
/// a 5-second auto-start countdown. Any user interaction cancels the countdown.
///
/// Returns a [SessionMeta] via `Navigator.pop(meta)` when the user taps
/// 'Start Recording' or the countdown reaches zero.
///
/// Usage:
/// ```dart
/// final meta = await showModalBottomSheet<SessionMeta>(
///   context: context,
///   isScrollControlled: true,
///   builder: (_) => const PreSessionCard(),
/// );
/// ```
class PreSessionCard extends ConsumerStatefulWidget {
  const PreSessionCard({super.key});

  @override
  ConsumerState<PreSessionCard> createState() => _PreSessionCardState();
}

class _PreSessionCardState extends ConsumerState<PreSessionCard> {
  final _driverController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();

  SurfaceCondition _surface = SurfaceCondition.SURFACE_CONDITION_DRY;
  SessionType _sessionType = SessionType.SESSION_TYPE_PRACTICE;

  bool _vehicleDetailsExpanded = false;
  bool _loading = true;

  // Autocomplete history lists.
  List<String> _driverHistory = [];
  List<String> _vehicleHistory = [];

  // Countdown state.
  int _countdown = 5;
  Timer? _countdownTimer;
  bool _countdownCancelled = false;
  bool _submitted = false;

  // Track which controllers have had listeners attached to avoid accumulation.
  final Set<TextEditingController> _listenersAttached = {};

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    final defaults = await SessionDefaults.load();
    final drivers = await SessionDefaults.driverHistory();
    final vehicles = await SessionDefaults.vehicleHistory();

    if (!mounted) return;

    setState(() {
      _driverController.text = defaults.driverName;
      _vehicleController.text = defaults.vehicle.name;
      _makeController.text = defaults.vehicle.make;
      _modelController.text = defaults.vehicle.model;
      if (defaults.vehicle.year > 0) {
        _yearController.text = defaults.vehicle.year.toString();
      }
      if (defaults.conditions.surface !=
          SurfaceCondition.SURFACE_CONDITION_UNSPECIFIED) {
        _surface = defaults.conditions.surface;
      }
      if (defaults.sessionType != SessionType.SESSION_TYPE_UNSPECIFIED) {
        _sessionType = defaults.sessionType;
      }
      _driverHistory = drivers;
      _vehicleHistory = vehicles;
      _loading = false;
    });

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        timer.cancel();
        _submit();
      }
    });
  }

  void _cancelCountdown() {
    if (_countdownCancelled) return;
    _countdownCancelled = true;
    _countdownTimer?.cancel();
    if (mounted) setState(() {});
  }

  SessionMeta _buildMeta() {
    final meta = SessionMeta()
      ..driverName = _driverController.text.trim()
      ..sessionType = _sessionType;

    final vehicle = Vehicle()
      ..name = _vehicleController.text.trim()
      ..make = _makeController.text.trim()
      ..model = _modelController.text.trim();
    final yearText = _yearController.text.trim();
    if (yearText.isNotEmpty) {
      final parsed = int.tryParse(yearText);
      if (parsed != null) vehicle.year = parsed;
    }
    meta.vehicle = vehicle;

    meta.conditions = Conditions()..surface = _surface;

    return meta;
  }

  void _submit() {
    if (_submitted) return; // Guard against double-submit.
    _submitted = true;
    _countdownTimer?.cancel();
    final meta = _buildMeta();

    // Save as defaults for next session.
    SessionDefaults.save(meta).catchError((_) {
      // Best-effort — don't block recording on defaults persistence failure.
    });

    Navigator.pop(context, meta);
  }

  /// Wraps a widget to cancel the countdown on any tap.
  Widget _interactionCanceller({required Widget child}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _cancelCountdown(),
      child: child,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _driverController.dispose();
    _vehicleController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _interactionCanceller(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: _loading
              ? const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Drag handle ─────────────────────────────
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Title ───────────────────────────────────
                      const Text(
                        'Session Setup',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Driver name ─────────────────────────────
                      _buildAutocompleteField(
                        controller: _driverController,
                        label: 'Driver',
                        icon: Icons.person_outline,
                        suggestions: _driverHistory,
                      ),
                      const SizedBox(height: 12),

                      // ── Vehicle name ────────────────────────────
                      _buildAutocompleteField(
                        controller: _vehicleController,
                        label: 'Vehicle',
                        icon: Icons.directions_car_outlined,
                        suggestions: _vehicleHistory,
                      ),
                      const SizedBox(height: 4),

                      // ── Vehicle details (expandable) ────────────
                      _buildVehicleDetailsExpander(),
                      const SizedBox(height: 16),

                      // ── Surface condition ───────────────────────
                      _buildSectionLabel('Surface'),
                      const SizedBox(height: 8),
                      _buildSurfaceToggle(),
                      const SizedBox(height: 16),

                      // ── Session type ────────────────────────────
                      _buildSectionLabel('Session Type'),
                      const SizedBox(height: 8),
                      _buildSessionTypeToggle(),
                      const SizedBox(height: 24),

                      // ── Start button ────────────────────────────
                      _buildStartButton(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets
  // ---------------------------------------------------------------------------

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildAutocompleteField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> suggestions,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return suggestions;
        return suggestions.where(
          (s) => s.toLowerCase().contains(textEditingValue.text.toLowerCase()),
        );
      },
      onSelected: (value) {
        controller.text = value;
        _cancelCountdown();
      },
      fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
        // Sync the provided controller's text into the autocomplete's own
        // controller on first build.
        if (textController.text.isEmpty && controller.text.isNotEmpty) {
          textController.text = controller.text;
        }
        // Keep our controller in sync — attach listener only once per instance.
        if (!_listenersAttached.contains(textController)) {
          _listenersAttached.add(textController);
          textController.addListener(
            () => controller.text = textController.text,
          );
        }

        return TextField(
          controller: textController,
          focusNode: focusNode,
          onTap: _cancelCountdown,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon: Icon(icon, color: AppColors.textDim, size: 20),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      option,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleDetailsExpander() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            _cancelCountdown();
            setState(() => _vehicleDetailsExpanded = !_vehicleDetailsExpanded);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _vehicleDetailsExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: AppColors.textDim,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'Vehicle details',
                  style: TextStyle(color: AppColors.textDim, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        if (_vehicleDetailsExpanded) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _makeController,
                  label: 'Make',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: _modelController,
                  label: 'Model',
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: _buildTextField(
                  controller: _yearController,
                  label: 'Year',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      onTap: _cancelCountdown,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSurfaceToggle() {
    return SegmentedButton<SurfaceCondition>(
      segments: const [
        ButtonSegment(
          value: SurfaceCondition.SURFACE_CONDITION_DRY,
          label: Text('Dry'),
          icon: Icon(Icons.wb_sunny_outlined, size: 16),
        ),
        ButtonSegment(
          value: SurfaceCondition.SURFACE_CONDITION_DAMP,
          label: Text('Damp'),
          icon: Icon(Icons.water_drop_outlined, size: 16),
        ),
        ButtonSegment(
          value: SurfaceCondition.SURFACE_CONDITION_WET,
          label: Text('Wet'),
          icon: Icon(Icons.water, size: 16),
        ),
      ],
      selected: {_surface},
      onSelectionChanged: (selected) {
        _cancelCountdown();
        setState(() => _surface = selected.first);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryMuted;
          }
          return AppColors.surfaceLight;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.textPrimary;
          }
          return AppColors.textSecondary;
        }),
        side: WidgetStateProperty.all(
          const BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
    );
  }

  Widget _buildSessionTypeToggle() {
    return SegmentedButton<SessionType>(
      segments: const [
        ButtonSegment(
          value: SessionType.SESSION_TYPE_PRACTICE,
          label: Text('Practice'),
        ),
        ButtonSegment(
          value: SessionType.SESSION_TYPE_QUALIFYING,
          label: Text('Quali'),
        ),
        ButtonSegment(
          value: SessionType.SESSION_TYPE_RACE,
          label: Text('Race'),
        ),
        ButtonSegment(
          value: SessionType.SESSION_TYPE_TEST,
          label: Text('Test'),
        ),
      ],
      selected: {_sessionType},
      onSelectionChanged: (selected) {
        _cancelCountdown();
        setState(() => _sessionType = selected.first);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryMuted;
          }
          return AppColors.surfaceLight;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.textPrimary;
          }
          return AppColors.textSecondary;
        }),
        side: WidgetStateProperty.all(
          const BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final showCountdown = !_countdownCancelled && _countdown > 0;
    final label = showCountdown
        ? 'Starting in $_countdown…'
        : 'Start Recording';

    return FilledButton.icon(
      onPressed: _submit,
      icon: const Icon(Icons.fiber_manual_record, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
