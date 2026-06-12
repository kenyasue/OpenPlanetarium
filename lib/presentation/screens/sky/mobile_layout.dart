import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/selection/selected_object_provider.dart';
import '../../widgets/glass_panel.dart';
import '../settings/settings_screen.dart';
import 'sky_canvas.dart';
import 'widgets/control_bar.dart';
import 'widgets/coordinate_display.dart';
import 'widgets/search_panel.dart';
import 'widgets/selected_object_panel.dart';

/// Mobile layout (width < 1024px).
///
/// Full-screen canvas + bottom control bar + selection chip (F13).
class MobileLayout extends ConsumerWidget {
  const MobileLayout({super.key});

  void _openSearchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xEE0A0F1E),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 16,
        ),
        child: SearchPanel(
          onResultSelected: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSelection = ref.watch(selectedObjectProvider) != null;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        const Positioned.fill(child: SkyCanvas()),
        // Search and settings buttons (top left, F13)
        Positioned(
          left: 12,
          top: 12 + topPadding,
          child: GlassPanel(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.search, size: 20),
                  onPressed: () => _openSearchSheet(context),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.settings, size: 20),
                  onPressed: () => SettingsScreen.open(context),
                ),
              ],
            ),
          ),
        ),
        // Current coordinates (AltAz / RA-Dec, top right)
        Positioned(
          right: 12,
          top: 12 + topPadding,
          child: const GlassPanel(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: CoordinateDisplay(),
          ),
        ),
        if (hasSelection)
          Positioned(
            left: 64,
            top: 16 + topPadding,
            child: const GlassPanel(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: SelectedObjectPanel(compact: true),
            ),
          ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12 + MediaQuery.paddingOf(context).bottom,
          child: const GlassPanel(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            // Show all controls on multiple rows instead of horizontal scrolling
            child: ControlBar(multiline: true),
          ),
        ),
      ],
    );
  }
}
