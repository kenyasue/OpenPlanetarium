import 'package:flutter/material.dart';

import '../../widgets/glass_panel.dart';
import '../settings/settings_screen.dart';
import 'sky_canvas.dart';
import 'widgets/control_bar.dart';
import 'widgets/coordinate_display.dart';
import 'widgets/search_panel.dart';
import 'widgets/selected_object_panel.dart';

/// Desktop layout (width ≥ 1024px).
///
/// Center: sky canvas (full screen) / left: search / right: object details /
/// bottom: control panel (aggregation of time and display settings, F13).
class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: SkyCanvas()),
        // Left panel (search + entry point to all settings)
        Positioned(
          left: 16,
          top: 16,
          width: 270,
          child: GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Search', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                const SearchPanel(),
                const Divider(height: 20),
                OutlinedButton.icon(
                  onPressed: () => SettingsScreen.open(context),
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Settings (constellations, data management, etc.)'),
                ),
              ],
            ),
          ),
        ),
        // Top right: current coordinates (AltAz / RA-Dec) + object detail panel
        const Positioned(
          right: 16,
          top: 16,
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassPanel(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: CoordinateDisplay(),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: 280,
                child: GlassPanel(child: SelectedObjectPanel()),
              ),
            ],
          ),
        ),
        // Bottom control panel (scrolls when width is insufficient)
        const Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GlassPanel(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ControlBar(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
