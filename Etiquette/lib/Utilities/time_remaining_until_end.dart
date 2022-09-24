String timeRemainingUntilEnd(String end_date) {
  final end_year = int.parse(end_date.substring(0, 4));
  final end_month = int.parse(end_date.substring(5, 7));
  final end_day = int.parse(end_date.substring(8, 10));
  final end_hour = int.parse(end_date.substring(11, 13));
  final end_minute = int.parse(end_date.substring(14, 16));
  final remaining = DateTime(end_year, end_month, end_day, end_hour, end_minute).difference(DateTime.now());
  return "${remaining.inDays}일 ${remaining.inHours % 24}시간 ${remaining.inMinutes % 60}분";
}