import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    hide GlassStyle, GlassIconButton, GlassPill;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:streak/app/theme/app_theme.dart';
import 'package:streak/core/widgets/glass.dart';

// Diagnostic capture: renders the tinted-glass pill and glass icon buttons
// in the LIGHT theme with a pale Nord-like primary, and saves PNGs under
// test/goldens/ for visual inspection.
// Run: flutter test --update-goldens test/golden_capture_test.dart
void main() {
  setUpAll(() async {
    await LiquidGlassWidgets.initialize(enablePerformanceMonitor: false);
  });

  Widget harness({required Color primary, required Widget child}) {
    return LiquidGlassWidgets.wrap(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(primary),
        home: Scaffold(
          backgroundColor: const Color(0xFFECEFF4),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (context) => GlassPill(
                    tint: primary,
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.plus,
                            size: 16,
                            color: GlassStyle.inkOn(context, primary)),
                        const SizedBox(width: 5),
                        Text(
                          'جدید',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: GlassStyle.inkOn(context, primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GlassIconButton(
                        icon: LucideIcons.notebookPen,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      GlassContainer(
                        width: 40,
                        height: 40,
                        padding: EdgeInsets.zero,
                        shape: const LiquidOval(),
                        color: GlassStyle.tint(context),
                        alignment: Alignment.center,
                        child: Icon(
                          LucideIcons.chevronsDownUp,
                          size: 19,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget body() => const SizedBox.shrink();

  testWidgets('default purple primary — light', (tester) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(harness(
      primary: const Color(0xFF7C3AED),
      child: body(),
    ));
    await tester.pump(const Duration(seconds: 1));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/pill_default_light.png'),
    );
  });

  testWidgets('pale nord primary — light', (tester) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(harness(
      primary: const Color(0xFF88C0D0),
      child: body(),
    ));
    await tester.pump(const Duration(seconds: 1));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/pill_nord_light.png'),
    );
  });
}
