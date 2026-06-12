import 'package:flutter/material.dart';

import 'desktop_layout.dart';
import 'mobile_layout.dart';

/// Breakpoint for desktop detection [logical px]
const double kDesktopBreakpoint = 1024;

/// Sky screen (home). Switches between desktop/mobile layouts based on screen width.
class SkyScreen extends StatelessWidget {
  const SkyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth >= kDesktopBreakpoint
              ? const DesktopLayout()
              : const MobileLayout();
        },
      ),
    );
  }
}
