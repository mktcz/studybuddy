abstract final class SbFormat {

  static String elapsed(Duration d) {
    final total = d.inSeconds.abs();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$m:$ss';
  }


  static String minutes(int totalMinutes) {
    if (totalMinutes <= 0) return '0m';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }


  static const unknown = '—';


  static String orUnknown(num? value, {String suffix = ''}) =>
      value == null ? unknown : '${value.round()}$suffix';


  static String relative(DateTime then, {DateTime? now}) {
    final delta = (now ?? DateTime.now()).difference(then);
    if (delta.inMinutes < 1) return 'just now';
    if (delta.inMinutes < 60) return '${delta.inMinutes}m ago';
    if (delta.inHours < 24) return '${delta.inHours}h ago';
    if (delta.inDays < 30) return '${delta.inDays}d ago';
    final months = delta.inDays ~/ 30;
    return months < 12 ? '${months}mo ago' : '${months ~/ 12}y ago';
  }
}
