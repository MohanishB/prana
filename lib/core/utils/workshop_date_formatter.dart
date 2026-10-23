/// Human-friendly workshop dates shared by list, detail and day-video screens.
/// Backend timestamps are local wall-clock values, not UTC instants.
class WorkshopDateFormatter {
  const WorkshopDateFormatter._();

  static DateTime? parse(String raw) {
    if (raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw.trim().replaceFirst(' ', 'T'));
  }

  static String unlock(String raw, {DateTime? now}) {
    final date = parse(raw);
    if (date == null) return raw;
    final today = now ?? DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final currentOnly = DateTime(today.year, today.month, today.day);
    final daysAway = dateOnly.difference(currentOnly).inDays;
    final prefix = switch (daysAway) {
      0 => 'Today',
      1 => 'Tomorrow',
      -1 => 'Yesterday',
      _ => '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}',
    };
    return '$prefix at ${_clock(date)}';
  }

  static String nextDay(int day, String raw, {DateTime? now}) =>
      'Day $day opens ${unlock(raw, now: now)}';

  static String _clock(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
}
