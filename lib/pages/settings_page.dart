import 'package:earthquake/controllers/app_controller.dart';
import 'package:earthquake/pages/homepage.dart';
import 'package:earthquake/utils/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    return Scaffold(
      appBar: AppBar(title: Text('Settings Page'), centerTitle: true),
      body: GetBuilder<AppController>(
        builder:
            (_) => ListView(
              padding: EdgeInsets.all(10),
              children: [
                Text(
                  'Time Setting',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Start Time'),
                        subtitle: Text(appController.startTime),
                        trailing: IconButton(
                          onPressed: () async {
                            final dt = await _datePicker();
                            if (dt != null) {
                              appController.setStartDate(dt);
                            }
                          },
                          icon: Icon(Icons.calendar_month),
                        ),
                      ), // set start Time
                      ListTile(
                        title: Text('End Time'),
                        subtitle: Text(appController.endTime),
                        trailing: IconButton(
                          onPressed: () async {
                            final dt = await _datePicker();
                            if (dt != null) {
                              appController.setEndDate(dt);
                            }
                          },
                          icon: Icon(Icons.calendar_month),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Location Setting',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Card(
                  child: SwitchListTile(
                    value: appController.shouldUseLocation,
                    title: Text(
                      appController.currentCity ?? 'Your Location Unknown',
                    ),
                    subtitle:
                        appController.currentCity == null
                            ? null
                            : Text(
                              'Your Location within ${appController.maxRadiusKm} km from your city ${appController.currentCity}',
                            ),
                    onChanged: (value) async {
                      EasyLoading.show(status: 'Getting your Location.....');
                      await appController.setLocation(value);
                      EasyLoading.dismiss();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Select Magnitude',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Slider(
                    value: appController.magnitude,
                    onChanged: (newMag) {
                      appController.setMagnitude(newMag);
                    },
                    min: 3,
                    max: 10,
                    divisions: 7,
                    label: appController.magnitude.round().toString(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Select Radius',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Slider(
                    value: appController.maxRadiusKm,
                    onChanged: (newRadius) {
                      appController.setMaxRadius(newRadius);
                    },
                    min: 500,
                    max: appController.maxRadiusKmThreshold,
                    divisions: 5,
                    label: appController.maxRadiusKm.round().toString(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    appController.getEarthquakeData();
                    Get.snackbar(
                      'Changes are successfully!',
                      'Information updated',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    Get.offAll(Homepage());
                  },
                  child: Text('Update'),
                ),
              ],
            ),
      ),
    );
  }

  Future<String?> _datePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      return getFormatTime(date.millisecondsSinceEpoch);
    }
    return null;
  }
}
