import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const String displayDatePattern = 'yyyy-MMM-dd';
const String displayDateTimePattern = 'EEE MMM dd yyyy hh:mm a';

String getFormatTime(num dt, [String pattern = displayDatePattern]) =>
    DateFormat(pattern).format(DateTime.fromMillisecondsSinceEpoch(dt.toInt()));

String formatDate(DateTime dt, [String pattern = displayDatePattern]) =>
    DateFormat(pattern).format(dt);

/// USGS expects ISO-8601 timestamps; values without an offset are read as UTC.
String toUsgsTime(DateTime dt) =>
    DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dt.toUtc());

Color magnitudeColor(num? mag) {
  final m = mag ?? 0;
  if (m >= 7) return Colors.red.shade700;
  if (m >= 6) return Colors.deepOrange;
  if (m >= 5) return Colors.orange;
  if (m >= 4) return Colors.amber.shade700;
  return Colors.green;
}

Color alertColor(String? alert) => switch (alert) {
  'green' => Colors.green,
  'yellow' => Colors.yellow,
  'orange' => Colors.orange,
  'red' => Colors.red,
  _ => Colors.grey,
};
