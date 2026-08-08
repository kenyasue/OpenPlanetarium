import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/time/time_controller.dart';
import 'package:open_planetarium/presentation/screens/sky/widgets/time_settings_dialog.dart';

void main() {
  late ProviderContainer container;

  Widget wrap() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: SingleChildScrollView(child: TimeSettingsContent()),
          ),
        ),
      ),
    );
  }

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  testWidgets('calendar date tap changes the date but keeps time of day', (
    tester,
  ) async {
    // Fixed observation time: 2026-08-15 21:30:45 local
    container
        .read(timeControllerProvider.notifier)
        .setTime(DateTime(2026, 8, 15, 21, 30, 45));
    await tester.pumpWidget(wrap());

    // Tap another day of the displayed month (Aug 2026)
    await tester.tap(find.text('20'));
    await tester.pump();

    final local = container.read(timeControllerProvider).toLocal();
    expect(local.year, 2026);
    expect(local.month, 8);
    expect(local.day, 20);
    expect(local.hour, 21);
    expect(local.minute, 30);
    expect(local.second, 45);
  });

  testWidgets('hour dropdown applies immediately and stops playback', (
    tester,
  ) async {
    container
        .read(timeControllerProvider.notifier)
        .setTime(DateTime(2026, 8, 15, 21, 30, 45));
    container.read(timePlaybackProvider.notifier).setSpeed(60);
    await tester.pumpWidget(wrap());

    // Drive the hour dropdown's onChanged directly: opening the overlay menu
    // is unstable in tests (the 24-entry menu scrolls to the selection), and
    // the behavior under test is the wiring to the providers, not the menu UI
    final hourDropdown = tester.widget<DropdownButton<int>>(
      find.byType(DropdownButton<int>).first,
    );
    expect(hourDropdown.value, 21);
    hourDropdown.onChanged!(5);
    await tester.pump();

    final local = container.read(timeControllerProvider).toLocal();
    expect(local.hour, 5);
    expect(local.minute, 30);
    expect(local.day, 15);
    expect(container.read(timePlaybackProvider), 0.0);
  });

  testWidgets('Now button resets to the current time', (tester) async {
    container
        .read(timeControllerProvider.notifier)
        .setTime(DateTime(2000, 1, 1, 0, 0, 0));
    await tester.pumpWidget(wrap());

    await tester.tap(find.text('Now'));
    await tester.pump();

    final diff = DateTime.now()
        .difference(container.read(timeControllerProvider).toLocal())
        .abs();
    expect(diff, lessThan(const Duration(seconds: 5)));
  });
}
