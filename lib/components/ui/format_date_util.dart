import 'package:cloud_firestore/cloud_firestore.dart';

class FormatDateUtil {
  static String formatDate(dynamic d) {
    DateTime? dt;
    if (d is Timestamp) dt = d.toDate();
    if (d is DateTime) dt = d;
    if (d is String) dt = DateTime.tryParse(d);
    dt ??= DateTime.now();

    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year às $hour:$minute';
  }
}
