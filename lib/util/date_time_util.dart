import 'package:intl/intl.dart';

class DateTimeUtil {
  final _timestampFormat = "yyyy-MM-dd HH:mm:ss";
  final _dateFormat = "yyyy-MM-dd";
  final _timeFormat = "hh:mm aa";

  String getCurrentTimestamp() {
    return DateFormat(_timestampFormat).format(DateTime.now());
  }

  String getCurrentDate() {
    return DateFormat(_dateFormat).format(DateTime.now());
  }

  String getCurrentTime() {
    return DateFormat(_timeFormat).format(DateTime.now());
  }
}