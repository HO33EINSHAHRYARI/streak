import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:streak/app/theme/app_tokens.dart';

typedef GlassNavItem = ({IconData icon, String label});

/// Authentic Liquid Glassmorphic Bottom Navigation Bar powered by liquid_glass_widgets.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onSelect,
    required this.compact,
  });

  final List<GlassNavItem> items;
  final int index;
  final ValueChanged<int> onSelect;
  final ValueListenable<bool> compact;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = context.tokens.muted;

    return ValueListenableBuilder<bool>(
      valueListenable: compact,
      builder: (context, isCompact, _) {
        return GlassTabBar.bottom(
          tabs: [
            for (final item in items)
              GlassTab(
                icon: Icon(item.icon),
                label: isCompact ? null : item.label,
              ),
          ],
          selectedIndex: index,
          onTabSelected: onSelect,
          barHeight: isCompact ? 52.0 : 64.0,
          horizontalPadding: 16.0,
          verticalPadding: 0.0,
          indicatorExpansion: EdgeInsets.zero,
          indicatorColor: scheme.primary.withValues(alpha: dark ? 0.30 : 0.22),
          selectedIconColor: scheme.primary,
          selectedLabelColor: scheme.primary,
          unselectedIconColor: muted,
          unselectedLabelColor: muted,
          glowDuration: const Duration(milliseconds: 280),
          glowBlurRadius: 24,
          glowOpacity: dark ? 0.35 : 0.20,
          indicatorPinchStrength: 0.0,
          magnification: 1.0,
        );
      },
    );
  }
}
