import 'package:flutter/material.dart';

import '../equipment/equipment_screen.dart';
import '../sky/widgets/constellation_settings_section.dart';
import '../sky/widgets/display_settings_section.dart';
import 'widgets/data_management_section.dart';
import 'widgets/location_section.dart';
import 'widgets/survey_settings_section.dart';

/// Settings screen (F4 + aggregation of various settings).
///
/// Sections: Display Settings / Constellation Display / Observing Location / Data Management.
/// The full 8-section layout (survey, language, etc.) will be expanded in M6/M8.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              _SectionCard(child: DisplaySettingsSection()),
              SizedBox(height: 12),
              _SectionCard(child: ConstellationSettingsSection()),
              SizedBox(height: 12),
              _SectionCard(child: SurveySettingsSection()),
              SizedBox(height: 12),
              _SectionCard(child: LocationSection()),
              SizedBox(height: 12),
              _SectionCard(child: DataManagementSection()),
              SizedBox(height: 12),
              _SectionCard(child: _EquipmentLink()),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipmentLink extends StatelessWidget {
  const _EquipmentLink();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Equipment', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => EquipmentScreen.open(context),
          icon: const Icon(Icons.build_outlined, size: 16),
          label: const Text('Equipment (telescopes, cameras, eyepieces, equipment sets)'),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}
