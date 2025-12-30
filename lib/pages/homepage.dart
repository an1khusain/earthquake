import 'package:earthquake/controllers/app_controller.dart';
import 'package:earthquake/pages/settings_page.dart';
import 'package:earthquake/utils/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.put(AppController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake App'),
        actions: [
          IconButton(onPressed: getSortDialog, icon: Icon(Icons.sort)),
          IconButton(onPressed: () {
            Get.to(SettingsPage());
          }, icon: Icon(Icons.settings)),
        ],
      ),
      body: GetBuilder<AppController>(
        builder:
            (_) =>
                appController.hasDataLoaded
                    ? ListView.builder(
                      itemCount:
                          appController.earthQuakeModel!.features!.length,
                      itemBuilder: (context, index) {
                        final data =
                            appController
                                .earthQuakeModel!
                                .features![index]
                                .properties!;
                        return ListTile(
                          onTap: () {
                            appController.openMap(data.place!);
                          },
                          title: Text(data.place ?? data.title ?? 'Unknown'),
                          subtitle: Text(
                            getFormatTime(
                              data.time!,
                              'EEE MMM dd yyyy hh:mm a',
                            ),
                          ),
                          trailing: Chip(
                            label: Text('${data.mag}'),
                            avatar:
                                data.alert == null
                                    ? null
                                    : CircleAvatar(
                                      backgroundColor: appController
                                          .getAlertColor(data.alert!),
                                    ),
                          ),
                        );
                      },
                    )
                    : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void getSortDialog() {
    AppController appController = Get.find<AppController>();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sort by'),
          content: GetBuilder<AppController>(builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioValue(
                groupValue: appController.orderBy,
                value: 'magnitude',
                label: 'Magnitude-Desc',
                onChange: (value) {
                  appController.setOrder(value!);
                  Navigator.pop(context);
                },
              ),
              RadioValue(
                groupValue: appController.orderBy,
                value: 'magnitude-asc',
                label: 'Magnitude-Asc',
                onChange: (value) {
                  appController.setOrder(value!);
                  Navigator.pop(context);
                },
              ),
              RadioValue(
                groupValue: appController.orderBy,
                value: 'time',
                label: 'Time-Desc',
                onChange: (value) {
                  appController.setOrder(value!);
                  Navigator.pop(context);
                },
              ),
              RadioValue(
                groupValue: appController.orderBy,
                value: 'time-asc',
                label: 'Time-Asc',
                onChange: (value) {
                  appController.setOrder(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          ),
        ));
  }
}

class RadioValue extends StatelessWidget {
  final String groupValue;
  final String value;
  final String label;
  final Function(String?) onChange;

  const RadioValue({
    super.key,
    required this.groupValue,
    required this.value,
    required this.label,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: onChange,
        ),
        Text(label),
      ],
    );
  }
}
