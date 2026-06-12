import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/download/download_controller.dart';
import '../../../../application/settings/download_settings_controller.dart';
import '../../../../domain/models/catalog_download.dart';

/// Data management section (F4: catalog downloads, storage, deletion, mode).
class DataManagementSection extends ConsumerWidget {
  const DataManagementSection({super.key});

  static const _modeLabels = {
    DownloadMode.auto: 'Auto',
    DownloadMode.wifiOnly: 'Wi-Fi Only',
    DownloadMode.manual: 'Manual',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final catalogs = ref.watch(availableCatalogsProvider);
    final downloadStates = ref.watch(downloadControllerProvider);
    final mode = ref.watch(downloadSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data Management', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'The default star catalog (up to magnitude 6.5, 8,920 stars) is '
          'bundled with the app and always available offline.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 12),
        Text(
          'Download Mode',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        SegmentedButton<DownloadMode>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: [
            for (final m in DownloadMode.values)
              ButtonSegment(value: m, label: Text(_modeLabels[m]!)),
          ],
          selected: {mode},
          onSelectionChanged: (selection) => ref
              .read(downloadSettingsProvider.notifier)
              .setMode(selection.first),
        ),
        if (mode == DownloadMode.wifiOnly &&
            !ref.watch(isMobilePlatformProvider))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'The Wi-Fi restriction applies only on mobile devices (no restriction on this device).',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
          ),
        const SizedBox(height: 12),
        Text(
          'Additional Catalogs',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        for (final catalog in catalogs)
          _CatalogTile(
            descriptor: catalog,
            state: downloadStates[catalog.id] ?? const CatalogDownloadState(),
          ),
      ],
    );
  }
}

class _CatalogTile extends ConsumerWidget {
  const _CatalogTile({required this.descriptor, required this.state});

  final CatalogDescriptor descriptor;
  final CatalogDownloadState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(downloadControllerProvider.notifier);

    final statusText = switch (state.status) {
      DownloadStatus.notDownloaded => 'Not downloaded',
      DownloadStatus.downloading =>
        'Downloading ${state.completedTiles}/${state.totalTiles}',
      DownloadStatus.failed => 'Failed: ${state.error ?? "Unknown error"}',
      DownloadStatus.downloaded => 'Downloaded',
    };

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(descriptor.name, style: theme.textTheme.bodyMedium),
              ),
              switch (state.status) {
                DownloadStatus.downloading => TextButton(
                  onPressed: () => controller.cancel(descriptor.id),
                  child: const Text('Cancel'),
                ),
                DownloadStatus.downloaded => TextButton(
                  onPressed: () => controller.deleteCatalog(descriptor.id),
                  child: const Text('Delete'),
                ),
                _ => TextButton(
                  onPressed: () => controller.startDownload(descriptor.id),
                  child: Text(
                    state.status == DownloadStatus.failed ? 'Retry' : 'Download',
                  ),
                ),
              },
            ],
          ),
          Text(
            descriptor.description,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 4),
          if (state.status == DownloadStatus.downloading)
            LinearProgressIndicator(value: state.progress, minHeight: 3),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: state.status == DownloadStatus.failed
                  ? theme.colorScheme.error
                  : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
