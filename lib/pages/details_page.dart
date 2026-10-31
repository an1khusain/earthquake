import 'package:earthquake/controllers/app_controller.dart';
import 'package:earthquake/models/earthquake_model.dart';
import 'package:earthquake/utils/helper_function.dart';
import 'package:earthquake/widgets/earthquake_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailsPage extends StatelessWidget {
  final Features feature;

  const DetailsPage({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();
    final p = feature.properties;
    final coords = feature.geometry?.coordinates;
    final theme = Theme.of(context);

    final rows = <(String, String)>[
      if (p?.mag != null)
        ('Magnitude', '${p!.mag}${p.magType == null ? '' : ' ${p.magType}'}'),
      if (p?.time != null)
        ('Time', getFormatTime(p!.time!, displayDateTimePattern)),
      if (coords != null && coords.length > 2)
        ('Depth', '${coords[2].toStringAsFixed(1)} km'),
      if (coords != null && coords.length >= 2)
        (
          'Coordinates',
          '${coords[1].toStringAsFixed(3)}, ${coords[0].toStringAsFixed(3)}',
        ),
      ('PAGER alert', p?.alert ?? 'None'),
      ('Tsunami warning', p?.tsunami == 1 ? 'Yes' : 'No'),
      if (p?.felt != null) ('Felt reports', '${p!.felt}'),
      if (p?.sig != null) ('Significance', '${p!.sig}'),
      if (p?.status != null) ('Status', p!.status!),
      if (p?.net != null) ('Network', p!.net!.toUpperCase()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Earthquake details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              MagnitudeBadge(mag: p?.mag, radius: 34),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  p?.place ?? p?.title ?? 'Unknown location',
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                for (final (label, value) in rows)
                  ListTile(
                    dense: true,
                    title: Text(label),
                    trailing: Text(value, style: theme.textTheme.bodyLarge),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => controller.openMap(feature),
            icon: const Icon(Icons.map),
            label: const Text('Open in Maps'),
          ),
          const SizedBox(height: 8),
          if (p?.url != null)
            OutlinedButton.icon(
              onPressed: () => controller.openUrl(p!.url),
              icon: const Icon(Icons.open_in_new),
              label: const Text('View on USGS'),
            ),
        ],
      ),
    );
  }
}
