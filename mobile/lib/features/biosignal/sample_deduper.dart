class SampleDeduper {
  SampleDeduper({this.capacity = 4096});

  final int capacity;
  final _seen = <String>{};

  bool accept({
    required String sessionId,
    required int seq,
    required int timestampMs,
  }) {
    if (sessionId.isEmpty) return false;
    final key = '$sessionId|$seq|$timestampMs';
    if (!_seen.add(key)) return false;
    while (_seen.length > capacity) {
      _seen.remove(_seen.first);
    }
    return true;
  }
}
