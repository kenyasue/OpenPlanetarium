import 'package:flutter/material.dart';

/// Shared settings dialog: scrollable [content] with a Close button.
///
/// Used by the control bar's settings icons and standalone dialogs (time
/// settings) so all settings popups share one look.
Future<void> showAppSettingDialog(
  BuildContext context,
  String title,
  Widget content, {
  double width = 360,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: width,
        child: SingleChildScrollView(child: content),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
