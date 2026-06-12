import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/models/equipment.dart';

const _uuid = Uuid();

/// Shared validator for numeric fields (positive numbers only)
String? _positiveNumber(String? value, String label) {
  final parsed = double.tryParse(value ?? '');
  if (parsed == null || parsed <= 0) return 'Enter a positive number for $label';
  return null;
}

TextFormField _numberField(
  TextEditingController controller,
  String label, {
  String? suffix,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffix,
      isDense: true,
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    validator: (v) => _positiveNumber(v, label),
  );
}

TextFormField _nameField(TextEditingController controller, String label) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label, isDense: true),
    validator: (v) => (v?.trim().isEmpty ?? true) ? '$label is required' : null,
  );
}

/// Shared base for form dialogs.
///
/// TextEditingControllers are managed within the State lifecycle
/// (initState/dispose). The showDialog Future completes at pop time, but
/// the widget tree stays alive during the dialog's exit animation, so
/// disposing in function scope (e.g. finally) causes a
/// "used after being disposed" controller crash.
abstract class _FormDialogState<W extends StatefulWidget, T> extends State<W> {
  final formKey = GlobalKey<FormState>();
  final _controllers = <TextEditingController>[];

  /// Call from initState. Creates a controller that is automatically released in dispose
  TextEditingController newController(String initialText) {
    final controller = TextEditingController(text: initialText);
    _controllers.add(controller);
    return controller;
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String get title;

  List<Widget> buildFields(BuildContext context);

  T buildResult();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 380,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buildFields(context),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(buildResult());
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ---- Telescope ----

Future<Telescope?> showTelescopeDialog(
  BuildContext context, {
  Telescope? existing,
}) {
  return showDialog<Telescope>(
    context: context,
    builder: (_) => _TelescopeDialog(existing: existing),
  );
}

class _TelescopeDialog extends StatefulWidget {
  const _TelescopeDialog({this.existing});

  final Telescope? existing;

  @override
  State<_TelescopeDialog> createState() => _TelescopeDialogState();
}

class _TelescopeDialogState
    extends _FormDialogState<_TelescopeDialog, Telescope> {
  late final TextEditingController _name;
  late final TextEditingController _aperture;
  late final TextEditingController _focalLength;
  late TelescopeType _type;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = newController(existing?.name ?? '');
    _aperture = newController(existing?.apertureMm.toString() ?? '');
    _focalLength = newController(existing?.focalLengthMm.toString() ?? '');
    _type = existing?.type ?? TelescopeType.refractor;
  }

  @override
  String get title =>
      widget.existing == null ? 'Add Telescope' : 'Edit Telescope';

  @override
  List<Widget> buildFields(BuildContext context) => [
    _nameField(_name, 'Name'),
    DropdownButtonFormField<TelescopeType>(
      initialValue: _type,
      decoration: const InputDecoration(labelText: 'Type', isDense: true),
      items: [
        for (final t in TelescopeType.values)
          DropdownMenuItem(value: t, child: Text(t.labelJa)),
      ],
      onChanged: (v) => setState(() => _type = v ?? _type),
    ),
    _numberField(_aperture, 'Aperture', suffix: 'mm'),
    _numberField(_focalLength, 'Focal Length', suffix: 'mm'),
  ];

  @override
  Telescope buildResult() => Telescope(
    id: widget.existing?.id ?? _uuid.v4(),
    name: _name.text.trim(),
    type: _type,
    apertureMm: double.parse(_aperture.text),
    focalLengthMm: double.parse(_focalLength.text),
  );
}

// ---- Camera ----

Future<CameraDevice?> showCameraDialog(
  BuildContext context, {
  CameraDevice? existing,
}) {
  return showDialog<CameraDevice>(
    context: context,
    builder: (_) => _CameraDialog(existing: existing),
  );
}

class _CameraDialog extends StatefulWidget {
  const _CameraDialog({this.existing});

  final CameraDevice? existing;

  @override
  State<_CameraDialog> createState() => _CameraDialogState();
}

class _CameraDialogState extends _FormDialogState<_CameraDialog, CameraDevice> {
  late final TextEditingController _name;
  late final TextEditingController _width;
  late final TextEditingController _height;
  late final TextEditingController _pixelSize;
  late final TextEditingController _resX;
  late final TextEditingController _resY;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = newController(existing?.name ?? '');
    _width = newController(existing?.sensorWidthMm.toString() ?? '');
    _height = newController(existing?.sensorHeightMm.toString() ?? '');
    _pixelSize = newController(existing?.pixelSizeUm.toString() ?? '');
    _resX = newController(existing?.resolutionX.toString() ?? '');
    _resY = newController(existing?.resolutionY.toString() ?? '');
  }

  @override
  String get title => widget.existing == null ? 'Add Camera' : 'Edit Camera';

  @override
  List<Widget> buildFields(BuildContext context) => [
    _nameField(_name, 'Camera Name'),
    _numberField(_width, 'Sensor Width', suffix: 'mm'),
    _numberField(_height, 'Sensor Height', suffix: 'mm'),
    _numberField(_pixelSize, 'Pixel Size', suffix: 'µm'),
    _numberField(_resX, 'Resolution (X)', suffix: 'px'),
    _numberField(_resY, 'Resolution (Y)', suffix: 'px'),
  ];

  @override
  CameraDevice buildResult() => CameraDevice(
    id: widget.existing?.id ?? _uuid.v4(),
    name: _name.text.trim(),
    sensorWidthMm: double.parse(_width.text),
    sensorHeightMm: double.parse(_height.text),
    pixelSizeUm: double.parse(_pixelSize.text),
    resolutionX: double.parse(_resX.text).round(),
    resolutionY: double.parse(_resY.text).round(),
  );
}

// ---- Eyepiece ----

Future<Eyepiece?> showEyepieceDialog(
  BuildContext context, {
  Eyepiece? existing,
}) {
  return showDialog<Eyepiece>(
    context: context,
    builder: (_) => _EyepieceDialog(existing: existing),
  );
}

class _EyepieceDialog extends StatefulWidget {
  const _EyepieceDialog({this.existing});

  final Eyepiece? existing;

  @override
  State<_EyepieceDialog> createState() => _EyepieceDialogState();
}

class _EyepieceDialogState extends _FormDialogState<_EyepieceDialog, Eyepiece> {
  late final TextEditingController _name;
  late final TextEditingController _focalLength;
  late final TextEditingController _afov;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = newController(existing?.name ?? '');
    _focalLength = newController(existing?.focalLengthMm.toString() ?? '');
    _afov = newController(existing?.apparentFovDeg.toString() ?? '');
  }

  @override
  String get title =>
      widget.existing == null ? 'Add Eyepiece' : 'Edit Eyepiece';

  @override
  List<Widget> buildFields(BuildContext context) => [
    _nameField(_name, 'Eyepiece Name'),
    _numberField(_focalLength, 'Focal Length', suffix: 'mm'),
    _numberField(_afov, 'Apparent FOV', suffix: '°'),
  ];

  @override
  Eyepiece buildResult() => Eyepiece(
    id: widget.existing?.id ?? _uuid.v4(),
    name: _name.text.trim(),
    focalLengthMm: double.parse(_focalLength.text),
    apparentFovDeg: double.parse(_afov.text),
  );
}

// ---- Barlow / Reducer ----

Future<OpticalModifier?> showModifierDialog(
  BuildContext context, {
  OpticalModifier? existing,
}) {
  return showDialog<OpticalModifier>(
    context: context,
    builder: (_) => _ModifierDialog(existing: existing),
  );
}

class _ModifierDialog extends StatefulWidget {
  const _ModifierDialog({this.existing});

  final OpticalModifier? existing;

  @override
  State<_ModifierDialog> createState() => _ModifierDialogState();
}

class _ModifierDialogState
    extends _FormDialogState<_ModifierDialog, OpticalModifier> {
  late final TextEditingController _name;
  late final TextEditingController _factor;
  late ModifierKind _kind;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = newController(existing?.name ?? '');
    _factor = newController(existing?.factor.toString() ?? '');
    _kind = existing?.kind ?? ModifierKind.barlow;
  }

  @override
  String get title => widget.existing == null
      ? 'Add Barlow/Reducer'
      : 'Edit Barlow/Reducer';

  @override
  List<Widget> buildFields(BuildContext context) => [
    _nameField(_name, 'Name'),
    DropdownButtonFormField<ModifierKind>(
      initialValue: _kind,
      decoration: const InputDecoration(labelText: 'Kind', isDense: true),
      items: [
        for (final k in ModifierKind.values)
          DropdownMenuItem(value: k, child: Text(k.labelJa)),
      ],
      onChanged: (v) => setState(() => _kind = v ?? _kind),
    ),
    _numberField(_factor, 'Factor', suffix: 'x'),
  ];

  @override
  OpticalModifier buildResult() => OpticalModifier(
    id: widget.existing?.id ?? _uuid.v4(),
    name: _name.text.trim(),
    kind: _kind,
    factor: double.parse(_factor.text),
  );
}

// ---- Equipment set ----

const _frameColors = [
  0xFF53C8E8, // Cyan
  0xFFE8A95B, // Orange
  0xFF9BE85B, // Green
  0xFFE85BC8, // Magenta
  0xFFE8E15B, // Yellow
];

Future<EquipmentSet?> showEquipmentSetDialog(
  BuildContext context, {
  required List<Telescope> telescopes,
  required List<CameraDevice> cameras,
  required List<Eyepiece> eyepieces,
  required List<OpticalModifier> modifiers,
  EquipmentSet? existing,
}) {
  return showDialog<EquipmentSet>(
    context: context,
    builder: (_) => _EquipmentSetDialog(
      telescopes: telescopes,
      cameras: cameras,
      eyepieces: eyepieces,
      modifiers: modifiers,
      existing: existing,
    ),
  );
}

class _EquipmentSetDialog extends StatefulWidget {
  const _EquipmentSetDialog({
    required this.telescopes,
    required this.cameras,
    required this.eyepieces,
    required this.modifiers,
    this.existing,
  });

  final List<Telescope> telescopes;
  final List<CameraDevice> cameras;
  final List<Eyepiece> eyepieces;
  final List<OpticalModifier> modifiers;
  final EquipmentSet? existing;

  @override
  State<_EquipmentSetDialog> createState() => _EquipmentSetDialogState();
}

class _EquipmentSetDialogState
    extends _FormDialogState<_EquipmentSetDialog, EquipmentSet> {
  late final TextEditingController _name;
  late String _telescopeId;
  late bool _isCameraMode;
  String? _cameraId;
  String? _eyepieceId;
  String? _modifierId;
  late int _colorArgb;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = newController(existing?.name ?? '');
    _telescopeId = existing?.telescopeId ?? widget.telescopes.first.id;
    _isCameraMode = existing?.isCameraMode ?? widget.cameras.isNotEmpty;
    _cameraId = existing?.cameraId ?? widget.cameras.firstOrNull?.id;
    _eyepieceId = existing?.eyepieceId ?? widget.eyepieces.firstOrNull?.id;
    _modifierId = existing?.modifierId;
    _colorArgb = existing?.frameColorArgb ?? _frameColors.first;
  }

  @override
  String get title =>
      widget.existing == null ? 'Create Equipment Set' : 'Edit Equipment Set';

  @override
  List<Widget> buildFields(BuildContext context) => [
    _nameField(_name, 'Set Name'),
    DropdownButtonFormField<String>(
      initialValue: _telescopeId,
      decoration: const InputDecoration(labelText: 'Telescope', isDense: true),
      items: [
        for (final t in widget.telescopes)
          DropdownMenuItem(value: t.id, child: Text(t.name)),
      ],
      onChanged: (v) => setState(() => _telescopeId = v ?? _telescopeId),
    ),
    const SizedBox(height: 8),
    SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: true, label: Text('Camera (imaging)')),
        ButtonSegment(value: false, label: Text('Eyepiece (visual)')),
      ],
      selected: {_isCameraMode},
      onSelectionChanged: (selection) =>
          setState(() => _isCameraMode = selection.first),
    ),
    if (_isCameraMode)
      DropdownButtonFormField<String>(
        // Reliably recreate the dropdown state when switching modes
        key: const ValueKey('camera'),
        initialValue: _cameraId,
        decoration: const InputDecoration(labelText: 'Camera', isDense: true),
        items: [
          for (final c in widget.cameras)
            DropdownMenuItem(value: c.id, child: Text(c.name)),
        ],
        onChanged: (v) => setState(() => _cameraId = v),
        validator: (v) => v == null ? 'Select a camera' : null,
      )
    else
      DropdownButtonFormField<String>(
        key: const ValueKey('eyepiece'),
        initialValue: _eyepieceId,
        decoration: const InputDecoration(labelText: 'Eyepiece', isDense: true),
        items: [
          for (final e in widget.eyepieces)
            DropdownMenuItem(value: e.id, child: Text(e.name)),
        ],
        onChanged: (v) => setState(() => _eyepieceId = v),
        validator: (v) => v == null ? 'Select an eyepiece' : null,
      ),
    DropdownButtonFormField<String?>(
      initialValue: _modifierId,
      decoration: const InputDecoration(
        labelText: 'Barlow/Reducer',
        isDense: true,
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('None')),
        for (final m in widget.modifiers)
          DropdownMenuItem(
            value: m.id,
            child: Text('${m.name} (${m.factor}x)'),
          ),
      ],
      onChanged: (v) => setState(() => _modifierId = v),
    ),
    const SizedBox(height: 12),
    Text('Frame Color', style: Theme.of(context).textTheme.bodySmall),
    const SizedBox(height: 4),
    Wrap(
      spacing: 8,
      children: [
        for (final color in _frameColors)
          GestureDetector(
            onTap: () => setState(() => _colorArgb = color),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Color(color),
                shape: BoxShape.circle,
                border: _colorArgb == color
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
            ),
          ),
      ],
    ),
  ];

  @override
  EquipmentSet buildResult() => EquipmentSet(
    id: widget.existing?.id ?? _uuid.v4(),
    name: _name.text.trim(),
    telescopeId: _telescopeId,
    cameraId: _isCameraMode ? _cameraId : null,
    eyepieceId: _isCameraMode ? null : _eyepieceId,
    modifierId: _modifierId,
    frameColorArgb: _colorArgb,
  );
}
