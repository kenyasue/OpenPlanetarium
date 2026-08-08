import 'package:flutter/material.dart';

/// Opens a searchable list picker and returns the chosen item (null when
/// dismissed).
///
/// Unlike Material's DropdownMenu — which builds a widget for every entry up
/// front and stalls the UI thread with large catalogs (ANR on Android with
/// 1,000+ cities) — the list here is built lazily with ListView.builder, so
/// only visible rows are instantiated.
Future<T?> showSearchPickerDialog<T>(
  BuildContext context, {
  required String title,
  required List<T> items,
  required String Function(T item) labelOf,
}) {
  return showDialog<T>(
    context: context,
    builder: (dialogContext) =>
        _SearchPickerDialog<T>(title: title, items: items, labelOf: labelOf),
  );
}

class _SearchPickerDialog<T> extends StatefulWidget {
  const _SearchPickerDialog({
    required this.title,
    required this.items,
    required this.labelOf,
  });

  final String title;
  final List<T> items;
  final String Function(T item) labelOf;

  @override
  State<_SearchPickerDialog<T>> createState() => _SearchPickerDialogState<T>();
}

class _SearchPickerDialogState<T> extends State<_SearchPickerDialog<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.items
        : [
            for (final item in widget.items)
              if (widget.labelOf(item).toLowerCase().contains(query)) item,
          ];

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SizedBox(
        width: 360,
        // Fixed height keeps the dialog stable while filtering
        height: 420,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Search',
                isDense: true,
                prefixIcon: Icon(Icons.search, size: 18),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No matches',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemExtent: 40,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            widget.labelOf(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// A tappable form field that displays the current selection and opens a
/// picker on tap (drop-in replacement look for a select box).
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
