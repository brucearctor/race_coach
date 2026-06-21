import 'dart:ui';

/// Racing-themed color palette for the Race Coach app.
///
/// All colors follow a dark-first design optimized for
/// in-car visibility under varying lighting conditions.
class AppColors {
  AppColors._();

  // ── Background & Surface ──────────────────────────────────────────────
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF1F252D);
  static const Color card = Color(0xFF1C2128);
  static const Color cardHover = Color(0xFF242A33);
  static const Color divider = Color(0xFF30363D);

  // ── Brand / Primary ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF58A6FF); // electric blue
  static const Color primaryDim = Color(0xFF388BFD);
  static const Color primaryMuted = Color(0xFF1F6FEB);

  // ── Accent / Speed ────────────────────────────────────────────────────
  static const Color accent = Color(0xFFF85149); // racing red
  static const Color accentDim = Color(0xFFDA3633);
  static const Color accentMuted = Color(0xFFB62324);

  // ── Semantic ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF3FB950); // green
  static const Color successDim = Color(0xFF2EA043);
  static const Color warning = Color(0xFFD29922); // amber
  static const Color warningDim = Color(0xFFBB8009);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xDEFFFFFF); // white 87%
  static const Color textSecondary = Color(0x99FFFFFF); // white 60%
  static const Color textDisabled = Color(0x61FFFFFF); // white 38%
  static const Color textHint = Color(0x42FFFFFF); // white 26%
  static const Color textDim = Color(0x4DFFFFFF); // white 30%

  // ── G-Force Colors ────────────────────────────────────────────────────
  /// Low g-force (cruising / light braking).
  static const Color gForceIdle = Color(0xFF3FB950);

  /// Moderate g-force (spirited driving).
  static const Color gForceModerate = Color(0xFFD29922);

  /// High g-force (hard braking / cornering).
  static const Color gForceHigh = Color(0xFFF85149);

  /// Extreme g-force (threshold / limit).
  static const Color gForceExtreme = Color(0xFFBC2F32);

  // ── Speed Gradient ────────────────────────────────────────────────────
  /// Colors for speed visualisation, ordered from slow → fast.
  static const List<Color> speedGradient = [
    Color(0xFF3FB950), // slow  – green
    Color(0xFF58A6FF), // mid   – blue
    Color(0xFFD29922), // fast  – amber
    Color(0xFFF85149), // very fast – red
  ];

  // ── Sector / Lap Delta ────────────────────────────────────────────────
  /// Driver is faster than reference.
  static const Color deltaFaster = Color(0xFF3FB950);

  /// Driver is slower than reference.
  static const Color deltaSlower = Color(0xFFF85149);

  /// Delta is neutral / negligible.
  static const Color deltaNeutral = Color(0xFF58A6FF);

  // ── Signal Strength ──────────────────────────────────────────────────
  static const Color signalExcellent = Color(0xFF3FB950);
  static const Color signalGood = Color(0xFF56D364);
  static const Color signalFair = Color(0xFFD29922);
  static const Color signalPoor = Color(0xFFF85149);
  static const Color signalNone = Color(0xFF484F58);
}
