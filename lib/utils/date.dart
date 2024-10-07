/// Simplify a `DateTime` to 0:00:00.000 of the same day, and convert it to UTC.
DateTime simplifyToDate(DateTime date) {
  var local = date.toLocal();
  return DateTime(local.year, local.month, local.day).toUtc();
}

String formatToLocalDate(DateTime date) {
  var local = date.toLocal();
  return "${local.year}年${local.month}月${local.day}日";
}
