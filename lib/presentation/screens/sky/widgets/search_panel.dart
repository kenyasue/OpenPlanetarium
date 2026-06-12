import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/search/search_service.dart';
import '../../../../application/selection/selected_object_provider.dart';
import '../../../../application/sky/solar_system_provider.dart';
import '../../../../application/viewport/viewport_controller.dart';
import '../../../../domain/models/sky_object.dart';

/// Celestial object search panel (F8). Shared by the desktop left panel and mobile sheet.
class SearchPanel extends ConsumerWidget {
  const SearchPanel({super.key, this.onResultSelected});

  /// Additional handling after a result is selected (e.g. closing the sheet on mobile)
  final VoidCallback? onResultSelected;

  void _selectResult(WidgetRef ref, SearchResult result) {
    // Solar system bodies are time-dependent, so resolve the current position when centering
    final target = switch (result.object) {
      SolarBodyObject(:final body) =>
        ref
                .read(solarSystemProvider)
                .where((p) => p.body == body)
                .firstOrNull
                ?.position ??
            result.target,
      _ => result.target,
    };
    ref
        .read(viewportControllerProvider.notifier)
        .centerOn(target, fovDeg: result.suggestedFovDeg);
    ref.read(selectedObjectProvider.notifier).select(result.object);
    onResultSelected?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          onChanged: (value) =>
              ref.read(searchQueryProvider.notifier).setQuery(value),
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'M31 / Sirius / Orion / Saturn',
            hintStyle: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white30,
            ),
            prefixIcon: const Icon(Icons.search, size: 18),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
        if (query.isNotEmpty) ...[
          const SizedBox(height: 8),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'No results found. Try something like M31 or Sirius.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white38,
                ),
              ),
            )
          else
            // List only the top 8 to avoid nesting with the scrolling parent (left panel)
            for (final result in results.take(8))
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                title: Text(result.label, style: theme.textTheme.bodyMedium),
                subtitle: Text(
                  result.sublabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
                onTap: () => _selectResult(ref, result),
              ),
        ],
      ],
    );
  }
}
