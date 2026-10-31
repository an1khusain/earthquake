import 'package:earthquake/controllers/app_controller.dart';
import 'package:earthquake/pages/details_page.dart';
import 'package:earthquake/pages/settings_page.dart';
import 'package:earthquake/widgets/earthquake_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const sortOptions = {
  'time': 'Newest first',
  'time-asc': 'Oldest first',
  'magnitude': 'Strongest first',
  'magnitude-asc': 'Weakest first',
};

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquakes'),
        actions: [
          IconButton(
            tooltip: 'Sort',
            onPressed: () => _showSortDialog(context, appController),
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () async {
              await Get.to(() => const SettingsPage());
              appController.refreshIfFiltersChanged();
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: GetBuilder<AppController>(
        builder: (c) {
          if (!c.hasDataLoaded) {
            if (c.errorMessage != null) {
              return _ErrorView(
                message: c.errorMessage!,
                onRetry: c.getEarthquakeData,
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
          final items = c.earthquakes;
          return RefreshIndicator(
            onRefresh: c.getEarthquakeData,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.isEmpty ? 2 : items.length + 1,
              separatorBuilder:
                  (_, i) =>
                      i == 0
                          ? const SizedBox.shrink()
                          : const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == 0) return _SummaryHeader(controller: c);
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No earthquakes match your filters.\n'
                        'Try a lower magnitude or a wider date range.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final feature = items[index - 1];
                return EarthquakeTile(
                  feature: feature,
                  onTap: () => Get.to(() => DetailsPage(feature: feature)),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showSortDialog(BuildContext context, AppController controller) {
    showDialog(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: const Text('Sort by'),
            children: [
              for (final entry in sortOptions.entries)
                ListTile(
                  title: Text(entry.value),
                  trailing:
                      controller.orderBy == entry.key
                          ? const Icon(Icons.check)
                          : null,
                  onTap: () {
                    Navigator.pop(context);
                    controller.setOrder(entry.key);
                  },
                ),
            ],
          ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final AppController controller;

  const _SummaryHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final f = c.appliedFilters!;
    final count = c.earthquakes.length;
    final location =
        f.nearMe
            ? 'within ${f.radiusKm.round()} km of ${f.city ?? 'your location'}'
            : 'worldwide';
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (c.isLoading) const LinearProgressIndicator(),
        if (c.errorMessage != null)
          Container(
            color: theme.colorScheme.errorContainer,
            padding: const EdgeInsets.all(12),
            child: Text(
              '${c.errorMessage!}\nShowing the previous results.',
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            '$count earthquake${count == 1 ? '' : 's'} '
            '(M${f.magnitude.toStringAsFixed(1)}+) $location\n'
            '${f.startTime} to ${f.endTime}  •  ${sortOptions[f.orderBy]}',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
