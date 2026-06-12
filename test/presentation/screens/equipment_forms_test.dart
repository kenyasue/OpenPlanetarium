import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/models/equipment.dart';
import 'package:open_planetarium/presentation/screens/equipment/widgets/equipment_forms.dart';

/// Regression tests covering equipment dialogs through completion of the
/// exit animation after save/cancel (prevents recurrence of the
/// "A TextEditingController was used after being disposed" crash).
void main() {
  Future<T?> openDialog<T>(
    WidgetTester tester,
    Future<T?> Function(BuildContext) show,
  ) async {
    T? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await show(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('add camera: no crash through input, save, and exit animation', (
    tester,
  ) async {
    CameraDevice? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => saved = await showCameraDialog(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'ASI294MC Pro');
    await tester.enterText(fields.at(1), '19.1');
    await tester.enterText(fields.at(2), '13.0');
    await tester.enterText(fields.at(3), '4.63');
    await tester.enterText(fields.at(4), '4144');
    await tester.enterText(fields.at(5), '2822');

    await tester.tap(find.text('Save'));
    // Advance the exit animation to the end (the old implementation crashed here)
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(saved, isNotNull);
    expect(saved!.name, 'ASI294MC Pro');
    expect(saved!.pixelSizeUm, 4.63);
  });

  testWidgets('add camera: cancel does not crash either', (tester) async {
    final result = await openDialog<CameraDevice>(
      tester,
      (context) => showCameraDialog(context),
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(result, isNull);
  });

  testWidgets(
    'create equipment set: no crash through save and exit animation',
    (tester) async {
      const telescope = Telescope(
        id: 't1',
        name: 'RASA 8',
        type: TelescopeType.rasa,
        apertureMm: 203,
        focalLengthMm: 400,
      );
      const camera = CameraDevice(
        id: 'c1',
        name: 'ASI294MC',
        sensorWidthMm: 19.1,
        sensorHeightMm: 13.0,
        pixelSizeUm: 4.63,
        resolutionX: 4144,
        resolutionY: 2822,
      );

      EquipmentSet? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => saved = await showEquipmentSetDialog(
                  context,
                  telescopes: const [telescope],
                  cameras: const [camera],
                  eyepieces: const [],
                  modifiers: const [],
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Deep Sky');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(saved, isNotNull);
      expect(saved!.name, 'Deep Sky');
      expect(saved!.isCameraMode, isTrue);
      expect(saved!.cameraId, 'c1');
    },
  );

  testWidgets(
    'add telescope: no crash after save (representative check for all types)',
    (tester) async {
      Telescope? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async =>
                    saved = await showTelescopeDialog(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'RASA 8');
      await tester.enterText(fields.at(1), '203');
      await tester.enterText(fields.at(2), '400');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(saved?.name, 'RASA 8');
    },
  );

  testWidgets(
    'validation: invalid number is not saved and the dialog stays open',
    (tester) async {
      await openDialog<Telescope>(
        tester,
        (context) => showTelescopeDialog(context),
      );
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'X');
      await tester.enterText(fields.at(1), '-5'); // invalid
      await tester.enterText(fields.at(2), '400');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a positive number for Aperture'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget); // dialog remains open
    },
  );
}
