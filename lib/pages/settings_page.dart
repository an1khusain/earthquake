import 'package:earthquake/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: GetBuilder<AppController>(
        builder:
            (c) => ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Text('Date range', style: titleStyle),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Start date'),
                        subtitle: Text(c.startTime),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          final date = await _pickDate(context, c.startDate);
                          if (date != null) c.setStartDate(date);
                        },
                      ),
                      ListTile(
                        title: const Text('End date'),
                        subtitle: Text(c.endTime),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          final date = await _pickDate(context, c.endDate);
                          if (date != null) c.setEndDate(date);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Minimum magnitude: ${c.magnitude.toStringAsFixed(1)}',
                  style: titleStyle,
                ),
                Slider(
                  value: c.magnitude,
                  min: AppController.minMagnitude,
                  max: AppController.maxMagnitude,
                  divisions: 20,
                  label: c.magnitude.toStringAsFixed(1),
                  onChanged: c.setMagnitude,
                ),
                const SizedBox(height: 12),
                Text('Location', style: titleStyle),
                Card(
                  child: SwitchListTile(
                    value: c.shouldUseLocation,
                    title: const Text('Only earthquakes near me'),
                    subtitle: Text(
                      c.shouldUseLocation
                          ? 'Near ${c.currentCity ?? '${c.latitude.toStringAsFixed(2)}, '
                                  '${c.longitude.toStringAsFixed(2)}'}'
                          : 'Showing earthquakes worldwide',
                    ),
                    onChanged: (value) async {
                      if (value) {
                        EasyLoading.show(status: 'Getting your location...');
                      }
                      final error = await c.setLocation(value);
                      EasyLoading.dismiss();
                      if (error != null) {
                        Get.snackbar(
                          'Location unavailable',
                          error,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Search radius: ${c.maxRadiusKm.round()} km',
                  style: titleStyle,
                ),
                Slider(
                  value: c.maxRadiusKm,
                  min: AppController.minRadiusKm,
                  max: AppController.maxRadiusKmThreshold,
                  divisions: 199,
                  label: '${c.maxRadiusKm.round()} km',
                  onChanged: c.shouldUseLocation ? c.setMaxRadius : null,
                ),
                if (!c.shouldUseLocation)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Turn on "near me" to limit the search radius.',
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: Get.back,
                  icon: const Icon(Icons.check),
                  label: const Text('Apply'),
                ),
              ],
            ),
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
  }
}
