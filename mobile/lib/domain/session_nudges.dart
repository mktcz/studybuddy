import 'enums.dart';
import 'study_logic.dart';


enum NudgeKind {

  breakSuggested,


  extendOffered,


  wrapUpSuggested,


  backOnTrack,
}

class Nudge {
  const Nudge({
    required this.kind,
    required this.at,
    required this.message,
    required this.watchMessage,
  });

  final NudgeKind kind;


  final DateTime at;

  final String message;


  final String watchMessage;
}

enum RestAlertKind { highStress, abnormalArousal, both }


class RestAlert {
  const RestAlert({
    required this.kind,
    required this.sessionId,
    required this.at,
    required this.stress,
    required this.arousal,
    required this.stressConfidence,
    required this.arousalConfidence,
    required this.focusActive,
    this.dismissed = false,
    this.acted = false,
  });

  final RestAlertKind kind;
  final String? sessionId;
  final DateTime at;
  final double? stress;
  final double? arousal;
  final double? stressConfidence;
  final double? arousalConfidence;
  final bool focusActive;
  final bool dismissed;
  final bool acted;

  String get message => NudgeEngine.restCopy;

  RestAlert copyWith({bool? dismissed, bool? acted, bool? focusActive}) {
    return RestAlert(
      kind: kind,
      sessionId: sessionId,
      at: at,
      stress: stress,
      arousal: arousal,
      stressConfidence: stressConfidence,
      arousalConfidence: arousalConfidence,
      focusActive: focusActive ?? this.focusActive,
      dismissed: dismissed ?? this.dismissed,
      acted: acted ?? this.acted,
    );
  }
}


class NudgeEngine {
  NudgeEngine({
    this.minConfidence = 0,
    this.globalCooldown = const Duration(minutes: 5),
    this.kindCooldown = const Duration(minutes: 10),
  });

  final double minConfidence;


  final Duration globalCooldown;

  final Duration kindCooldown;

  static const _minBreakElapsed = Duration(minutes: 10);
  static const _minWrapUpElapsed = Duration(minutes: 15);
  static const _extendWindow = Duration(minutes: 5);

  final List<double> _stress = [];
  final List<double> _focus = [];
  final List<double> _capacity = [];
  final Map<NudgeKind, DateTime> _lastFired = {};
  DateTime? _lastAnyFired;
  double? _peakCapacityMean;
  double? _stressAtBreakAlert;
  bool _extendConsumed = false;
  bool _wrapUpFired = false;
  bool _extendFired = false;


  Nudge? onWindow({
    required StateSample sample,
    required Duration elapsed,
    required Duration planned,
  }) {
    if (sample.origin == SignalOrigin.unmeasured) return null;
    _accumulate(sample);

    final kind = _evaluate(sample.at, elapsed, planned);
    if (kind == null) return null;
    _record(kind, sample.at);
    return _build(kind, sample.at);
  }


  void onExtended() => _extendConsumed = true;


  void reset() {
    _stress.clear();
    _focus.clear();
    _capacity.clear();
    _lastFired.clear();
    _lastAnyFired = null;
    _peakCapacityMean = null;
    _stressAtBreakAlert = null;
    _extendConsumed = false;
    _wrapUpFired = false;
    _extendFired = false;
    resetRestEpisode();
  }

  void _accumulate(StateSample sample) {
    void keep(List<double> series, double? value, double? confidence) {
      if (value == null) return;
      if (minConfidence > 0 && (confidence ?? 0) < minConfidence) return;
      series.add(value);
    }

    keep(_stress, sample.stress, sample.stressConfidence);
    keep(_focus, sample.focus, sample.focusConfidence);
    keep(_capacity, sample.capacity, sample.capacityConfidence);

    if (_capacity.length >= 3) {
      final mean = _meanOfLast(_capacity, 3)!;
      if (_peakCapacityMean == null || mean > _peakCapacityMean!) {
        _peakCapacityMean = mean;
      }
    }
  }

  NudgeKind? _evaluate(DateTime at, Duration elapsed, Duration planned) {
    final last = _lastAnyFired;
    if (last != null && at.difference(last) < globalCooldown) return null;

    if (_shouldSuggestBreak(elapsed) &&
        _kindReady(NudgeKind.breakSuggested, at)) {
      return NudgeKind.breakSuggested;
    }
    if (_shouldSuggestWrapUp(elapsed)) return NudgeKind.wrapUpSuggested;
    if (_shouldOfferExtend(at, elapsed, planned)) {
      return NudgeKind.extendOffered;
    }
    if (_isBackOnTrack()) return NudgeKind.backOnTrack;
    return null;
  }

  bool _shouldSuggestBreak(Duration elapsed) {
    if (elapsed < _minBreakElapsed) return false;
    final n = _stress.length;

    if (n >= 2 && _stress[n - 1] >= 0.75 && _stress[n - 2] >= 0.75) return true;
    if (n < 3) return false;
    final a = _stress[n - 3], b = _stress[n - 2], c = _stress[n - 1];
    const tolerance = 0.02;
    final nonDecreasing = b >= a - tolerance && c >= b - tolerance;
    return nonDecreasing && c - a >= 0.10 && c >= 0.60;
  }

  bool _shouldSuggestWrapUp(Duration elapsed) {
    if (_wrapUpFired || elapsed < _minWrapUpElapsed) return false;
    final peak = _peakCapacityMean;
    final mean = _meanOfLast(_capacity, 3);
    if (peak == null || mean == null) return false;
    return peak - mean >= 0.15 && _capacity.last <= 0.40;
  }

  bool _shouldOfferExtend(DateTime at, Duration elapsed, Duration planned) {
    if (_extendFired || _extendConsumed) return false;
    final remaining = planned - elapsed;
    if (remaining <= Duration.zero || remaining > _extendWindow) return false;

    for (final kind in const [
      NudgeKind.breakSuggested,
      NudgeKind.wrapUpSuggested,
    ]) {
      final fired = _lastFired[kind];
      if (fired != null && at.difference(fired) < kindCooldown) return false;
    }
    final focusMean = _meanOfLast(_focus, 3);
    if (focusMean == null || focusMean < 0.65) return false;
    final stressMean = _meanOfLast(_stress, 3);
    return stressMean == null || stressMean <= 0.45;
  }

  bool _isBackOnTrack() {
    final alertStress = _stressAtBreakAlert;
    final n = _stress.length;
    if (alertStress == null || n < 2) return false;
    final b = _stress[n - 2], c = _stress[n - 1];
    return b <= 0.45 && c <= 0.45 && c <= alertStress - 0.10;
  }

  bool _kindReady(NudgeKind kind, DateTime at) {
    final fired = _lastFired[kind];
    return fired == null || at.difference(fired) >= kindCooldown;
  }

  void _record(NudgeKind kind, DateTime at) {
    _lastFired[kind] = at;
    _lastAnyFired = at;
    switch (kind) {
      case NudgeKind.breakSuggested:
        _stressAtBreakAlert = _stress.isEmpty ? null : _stress.last;
      case NudgeKind.wrapUpSuggested:
        _wrapUpFired = true;
      case NudgeKind.extendOffered:
        _extendFired = true;
      case NudgeKind.backOnTrack:
        _stressAtBreakAlert = null;
    }
  }

  Nudge _build(NudgeKind kind, DateTime at) => switch (kind) {
    NudgeKind.breakSuggested => Nudge(
      kind: kind,
      at: at,
      message: 'Stress has been climbing — a short break may help.',
      watchMessage: 'Stress rising — break?',
    ),
    NudgeKind.extendOffered => Nudge(
      kind: kind,
      at: at,
      message: "You're pacing well. Extend by 10 minutes?",
      watchMessage: 'Flowing — extend?',
    ),
    NudgeKind.wrapUpSuggested => Nudge(
      kind: kind,
      at: at,
      message: 'Capacity is fading — a good moment to wrap up.',
      watchMessage: 'Fading — wrap up?',
    ),
    NudgeKind.backOnTrack => Nudge(
      kind: kind,
      at: at,
      message: "Stress settled — you're back on track.",
      watchMessage: 'Back on track',
    ),
  };


  static const restCopy = 'Your measured state suggests taking a short rest.';
  static const restDisclaimer = 'This is not a medical diagnosis or advice.';
  static const restStressThreshold = 0.75;
  static const restArousalLow = 0.20;
  static const restArousalHigh = 0.80;
  static const restMaxAge = Duration(minutes: 3);
  static const restMaxSkew = Duration(seconds: 30);
  static const restMinGap = Duration(seconds: 20);
  static const restMaxGap = Duration(minutes: 2, seconds: 30);

  RestAlert? _pendingRest;
  String? _restSessionId;
  DateTime? _lastRestFired;
  DateTime? _lastRestSampleAt;
  int _restQualifyingStreak = 0;
  bool _restEpisodeOpen = false;
  bool _restEpisodeSuppressed = false;

  RestAlert? get pendingRestAlert => _pendingRest;


  RestAlert? onRestWindow({
    required StateSample sample,
    required String? sessionId,
    required bool focusActive,
    DateTime? now,
  }) {
    if (sessionId != _restSessionId) {
      resetRestEpisode(sessionId: sessionId);
    }
    if (sample.origin == SignalOrigin.unmeasured) return null;

    final clock = now ?? DateTime.now();
    final age = clock.difference(sample.at);
    if (age > restMaxAge) return null;
    if (sample.at.isAfter(clock.add(restMaxSkew))) return null;

    final previous = _lastRestSampleAt;
    if (previous != null && sample.at.isBefore(previous)) return null;

    if (!_restQualifies(sample)) {
      _restQualifyingStreak = 0;
      _lastRestSampleAt = sample.at;
      if (_restEpisodeOpen && _pendingRest == null) {
        _restEpisodeOpen = false;
        _restEpisodeSuppressed = false;
      }
      return null;
    }

    if (previous != null) {
      final gap = sample.at.difference(previous);
      if (gap < restMinGap) return null;
      if (gap > restMaxGap) _restQualifyingStreak = 0;
    }

    _lastRestSampleAt = sample.at;
    _restQualifyingStreak += 1;
    if (_restQualifyingStreak < 2) return null;
    if (_restEpisodeSuppressed) return null;
    if (_pendingRest != null) return null;
    final last = _lastRestFired;
    if (last != null && sample.at.difference(last) < globalCooldown) {
      return null;
    }

    final highStress =
        _positive(sample.stress, sample.stressConfidence) &&
        sample.stress! >= restStressThreshold;
    final abnormalArousal =
        _positive(sample.arousal, sample.arousalConfidence) &&
        (sample.arousal! < restArousalLow || sample.arousal! > restArousalHigh);
    final kind = switch ((highStress, abnormalArousal)) {
      (true, true) => RestAlertKind.both,
      (false, true) => RestAlertKind.abnormalArousal,
      _ => RestAlertKind.highStress,
    };
    final alert = RestAlert(
      kind: kind,
      sessionId: sessionId,
      at: sample.at,
      stress: sample.stress,
      arousal: sample.arousal,
      stressConfidence: sample.stressConfidence,
      arousalConfidence: sample.arousalConfidence,
      focusActive: focusActive,
    );
    _pendingRest = alert;
    _restEpisodeOpen = true;
    _lastRestFired = sample.at;
    return alert;
  }

  void dismissRestAlert() {
    _restEpisodeSuppressed = true;
    _pendingRest = _pendingRest?.copyWith(dismissed: true);
    _pendingRest = null;
  }

  void actOnRestAlert() {
    _restEpisodeSuppressed = true;
    _pendingRest = _pendingRest?.copyWith(acted: true);
    _pendingRest = null;
  }


  void dropPendingPresentation() {
    _pendingRest = null;
    _restQualifyingStreak = 0;
    _lastRestSampleAt = null;
  }

  void resetRestEpisode({String? sessionId}) {
    _restQualifyingStreak = 0;
    _pendingRest = null;
    _restEpisodeOpen = false;
    _restEpisodeSuppressed = false;
    _restSessionId = sessionId;
    _lastRestSampleAt = null;
  }

  bool _restQualifies(StateSample sample) {
    final highStress =
        _positive(sample.stress, sample.stressConfidence) &&
        sample.stress! >= restStressThreshold;
    final abnormalArousal =
        _positive(sample.arousal, sample.arousalConfidence) &&
        (sample.arousal! < restArousalLow || sample.arousal! > restArousalHigh);
    return highStress || abnormalArousal;
  }

  bool _positive(double? value, double? confidence) {
    if (value == null || !value.isFinite) return false;
    if (confidence == null || !confidence.isFinite || confidence <= 0) {
      return false;
    }
    return true;
  }

  double? _meanOfLast(List<double> series, int count) {
    if (series.length < count) return null;
    var sum = 0.0;
    for (var i = series.length - count; i < series.length; i++) {
      sum += series[i];
    }
    return sum / count;
  }
}
