import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/session/data/session_meta_storage.dart';
import 'package:race_coach/generated/racecoach/v1/session.pb.dart';

// =============================================================================
// SessionMetaEditor — full-screen metadata editor
// =============================================================================

/// A full-screen editor for viewing and editing [SessionMeta].
///
/// Pass an existing [meta] for post-session editing, or `null` to create new
/// metadata. The [sessionId] is required so we know where to save.
///
/// Push as a full-screen route:
/// ```dart
/// Navigator.of(context).push(MaterialPageRoute(
///   fullscreenDialog: true,
///   builder: (_) => SessionMetaEditor(
///     sessionId: session.sessionId,
///     meta: existingMeta,
///   ),
/// ));
/// ```
class SessionMetaEditor extends ConsumerStatefulWidget {
  const SessionMetaEditor({super.key, required this.sessionId, this.meta});

  final String sessionId;
  final SessionMeta? meta;

  @override
  ConsumerState<SessionMetaEditor> createState() => _SessionMetaEditorState();
}

class _SessionMetaEditorState extends ConsumerState<SessionMetaEditor> {
  // ── Driver ──────────────────────────────────────────────────────────────
  late final TextEditingController _driverController;

  // ── Vehicle ─────────────────────────────────────────────────────────────
  late final TextEditingController _vehicleNameController;
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _classController;
  late final TextEditingController _weightController;
  late final TextEditingController _powerController;
  late final TextEditingController _tireCompoundController;
  late final TextEditingController _tireFLController;
  late final TextEditingController _tireFRController;
  late final TextEditingController _tireRLController;
  late final TextEditingController _tireRRController;

  // ── Conditions ──────────────────────────────────────────────────────────
  late SurfaceCondition _surface;
  late final TextEditingController _ambientTempController;
  late final TextEditingController _trackTempController;
  late final TextEditingController _humidityController;

  // ── Session ─────────────────────────────────────────────────────────────
  late SessionType _sessionType;
  late final TextEditingController _notesController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.meta ?? SessionMeta();
    final v = m.vehicle;
    final c = m.conditions;
    final tp = v.tirePressures;

    _driverController = TextEditingController(text: m.driverName);

    _vehicleNameController = TextEditingController(text: v.name);
    _makeController = TextEditingController(text: v.make);
    _modelController = TextEditingController(text: v.model);
    _yearController = TextEditingController(
      text: v.year > 0 ? v.year.toString() : '',
    );
    _classController = TextEditingController(text: v.vehicleClass);
    _weightController = TextEditingController(
      text: v.weightKg > 0 ? v.weightKg.toStringAsFixed(0) : '',
    );
    _powerController = TextEditingController(
      text: v.powerHp > 0 ? v.powerHp.toStringAsFixed(0) : '',
    );
    _tireCompoundController = TextEditingController(text: v.tireCompound);
    _tireFLController = TextEditingController(
      text: tp.frontLeftPsi > 0 ? tp.frontLeftPsi.toStringAsFixed(1) : '',
    );
    _tireFRController = TextEditingController(
      text: tp.frontRightPsi > 0 ? tp.frontRightPsi.toStringAsFixed(1) : '',
    );
    _tireRLController = TextEditingController(
      text: tp.rearLeftPsi > 0 ? tp.rearLeftPsi.toStringAsFixed(1) : '',
    );
    _tireRRController = TextEditingController(
      text: tp.rearRightPsi > 0 ? tp.rearRightPsi.toStringAsFixed(1) : '',
    );

    _surface = c.surface;
    _ambientTempController = TextEditingController(
      text: c.ambientTempC != 0 ? c.ambientTempC.toStringAsFixed(1) : '',
    );
    _trackTempController = TextEditingController(
      text: c.trackTempC != 0 ? c.trackTempC.toStringAsFixed(1) : '',
    );
    _humidityController = TextEditingController(
      text: c.humidityPct != 0 ? c.humidityPct.toStringAsFixed(0) : '',
    );

    _sessionType = m.sessionType;
    _notesController = TextEditingController(text: m.notes);
  }

  @override
  void dispose() {
    _driverController.dispose();
    _vehicleNameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _classController.dispose();
    _weightController.dispose();
    _powerController.dispose();
    _tireCompoundController.dispose();
    _tireFLController.dispose();
    _tireFRController.dispose();
    _tireRLController.dispose();
    _tireRRController.dispose();
    _ambientTempController.dispose();
    _trackTempController.dispose();
    _humidityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  SessionMeta _buildMeta() {
    final meta = widget.meta?.deepCopy() ?? SessionMeta();
    meta.sessionId = widget.sessionId;
    meta.driverName = _driverController.text.trim();
    meta.sessionType = _sessionType;
    meta.notes = _notesController.text.trim();

    // Set createdAt for new metadata (old sessions getting metadata added).
    if (widget.meta == null) {
      final now = DateTime.now();
      final ms = now.millisecondsSinceEpoch;
      meta.createdAt = Timestamp(
        seconds: Int64(ms ~/ 1000),
        nanos: (ms % 1000) * 1000000,
      );
    }

    // Vehicle.
    final vehicle = meta.ensureVehicle()
      ..name = _vehicleNameController.text.trim()
      ..make = _makeController.text.trim()
      ..model = _modelController.text.trim()
      ..vehicleClass = _classController.text.trim()
      ..tireCompound = _tireCompoundController.text.trim();

    final year = int.tryParse(_yearController.text.trim());
    if (year != null) vehicle.year = year;
    final weight = double.tryParse(_weightController.text.trim());
    if (weight != null) vehicle.weightKg = weight;
    final power = double.tryParse(_powerController.text.trim());
    if (power != null) vehicle.powerHp = power;

    // Tire pressures.
    final tp = vehicle.ensureTirePressures();
    final fl = double.tryParse(_tireFLController.text.trim());
    if (fl != null) tp.frontLeftPsi = fl;
    final fr = double.tryParse(_tireFRController.text.trim());
    if (fr != null) tp.frontRightPsi = fr;
    final rl = double.tryParse(_tireRLController.text.trim());
    if (rl != null) tp.rearLeftPsi = rl;
    final rr = double.tryParse(_tireRRController.text.trim());
    if (rr != null) tp.rearRightPsi = rr;

    // Conditions.
    final conditions = meta.ensureConditions()..surface = _surface;
    final at = double.tryParse(_ambientTempController.text.trim());
    if (at != null) conditions.ambientTempC = at;
    final tt = double.tryParse(_trackTempController.text.trim());
    if (tt != null) conditions.trackTempC = tt;
    final hum = double.tryParse(_humidityController.text.trim());
    if (hum != null) conditions.humidityPct = hum;

    return meta;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final meta = _buildMeta();
      final storage = ref.read(sessionMetaStorageProvider);
      await storage.save(widget.sessionId, meta);
      if (mounted) {
        Navigator.of(context).pop(true); // true = saved
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Session Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Driver ──────────────────────────────────────────────────
          _buildSectionHeader('Driver'),
          const SizedBox(height: 8),
          _buildField(
            _driverController,
            'Driver name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 24),

          // ── Vehicle ─────────────────────────────────────────────────
          _buildSectionHeader('Vehicle'),
          const SizedBox(height: 8),
          _buildField(
            _vehicleNameController,
            'Vehicle name',
            icon: Icons.directions_car_outlined,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildField(_makeController, 'Make')),
              const SizedBox(width: 8),
              Expanded(child: _buildField(_modelController, 'Model')),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: _buildField(
                  _yearController,
                  'Year',
                  keyboard: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildField(_classController, 'Class')),
              const SizedBox(width: 8),
              Expanded(
                child: _buildField(
                  _weightController,
                  'Weight (kg)',
                  keyboard: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildField(
                  _powerController,
                  'Power (hp)',
                  keyboard: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildField(_tireCompoundController, 'Tire compound'),
          const SizedBox(height: 8),
          _buildSectionLabel('Cold tire pressures (PSI)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  _tireFLController,
                  'FL',
                  keyboard: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildField(
                  _tireFRController,
                  'FR',
                  keyboard: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildField(
                  _tireRLController,
                  'RL',
                  keyboard: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildField(
                  _tireRRController,
                  'RR',
                  keyboard: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Conditions ──────────────────────────────────────────────
          _buildSectionHeader('Conditions'),
          const SizedBox(height: 8),
          _buildSectionLabel('Surface'),
          const SizedBox(height: 8),
          _buildSurfaceToggle(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  _ambientTempController,
                  'Ambient °C',
                  keyboard: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildField(
                  _trackTempController,
                  'Track °C',
                  keyboard: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildField(
                  _humidityController,
                  'Humidity %',
                  keyboard: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Session type ────────────────────────────────────────────
          _buildSectionHeader('Session'),
          const SizedBox(height: 8),
          _buildSessionTypeToggle(),
          const SizedBox(height: 12),

          // ── Notes ───────────────────────────────────────────────────
          TextField(
            controller: _notesController,
            maxLines: 4,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Notes',
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              alignLabelWithHint: true,
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
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Builder helpers
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    IconData? icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textDim, size: 20)
            : null,
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
          label: Text('Qualifying'),
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
}
