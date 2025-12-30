import 'package:intl/intl.dart';

String getFormatTime(num dt, [String pattern = 'yyyy-MMM-dd']) =>
    DateFormat(pattern).format(DateTime.fromMillisecondsSinceEpoch(dt.toInt()));