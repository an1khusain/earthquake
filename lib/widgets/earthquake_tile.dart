import 'package:earthquake/models/earthquake_model.dart';
import 'package:earthquake/utils/helper_function.dart';
import 'package:flutter/material.dart';

class EarthquakeTile extends StatelessWidget {
  final Features feature;
  final VoidCallback? onTap;

  const EarthquakeTile({super.key, required this.feature, this.onTap});

  @override
  Widget build(BuildContext context) {
    final data = feature.properties;
    final coords = feature.geometry?.coordinates;
    final depth = coords != null && coords.length > 2 ? coords[2] : null;
    final subtitle = [
      if (data?.time != null)
        getFormatTime(data!.time!, displayDateTimePattern),
      if (depth != null) 'Depth ${depth.toStringAsFixed(1)} km',
    ].join('  •  ');

    return ListTile(
      onTap: onTap,
      leading: MagnitudeBadge(mag: data?.mag),
      title: Text(data?.place ?? data?.title ?? 'Unknown location'),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data?.tsunami == 1)
            const Tooltip(
              message: 'Tsunami warning',
              child: Icon(Icons.waves, color: Colors.lightBlueAccent),
            ),
          if (data?.alert != null)
            Tooltip(
              message: 'PAGER alert: ${data!.alert}',
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor: alertColor(data.alert),
                ),
              ),
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class MagnitudeBadge extends StatelessWidget {
  final num? mag;
  final double radius;

  const MagnitudeBadge({super.key, required this.mag, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: magnitudeColor(mag),
      child: Text(
        mag == null ? '?' : mag!.toStringAsFixed(1),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.6,
        ),
      ),
    );
  }
}
