import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Directional icons that read correctly in both LTR and RTL layouts.
///
/// "Forward" (deeper into a page / next period) points left in RTL;
/// "back" (up one level / previous period) points right in RTL.
IconData chevronForward(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl
        ? LucideIcons.chevronLeft
        : LucideIcons.chevronRight;

IconData chevronBack(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl
        ? LucideIcons.chevronRight
        : LucideIcons.chevronLeft;

IconData arrowForward(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl
        ? LucideIcons.arrowLeft
        : LucideIcons.arrowRight;

IconData arrowBack(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl
        ? LucideIcons.arrowRight
        : LucideIcons.arrowLeft;
