import 'package:intl/intl.dart';

class Formatters {
  static String dateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm', 'id').format(date.toLocal());
  }

  static String date(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy', 'id').format(date.toLocal());
  }
}
