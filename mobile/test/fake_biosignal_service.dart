import 'dart:async';

import 'package:studybuddy/domain/enums.dart';
import 'package:studybuddy/features/biosignal/bio_reading.dart';
import 'package:studybuddy/features/biosignal/biosignal_service.dart';
import 'package:synheart_session/synheart_session.dart' as sh;


class FakeBiosignalService implements BiosignalService {
  FakeBiosignalService({
    this.watchReady = true,
    this.outcomeOnStop = const BioOutcome(
      origin: SignalOrigin.wearableReal,
      acceptedSamples: 30,
    ),
  });

  final bool watchReady;
  final BioOutcome outcomeOnStop;

  final _readings = StreamController<BioReading>.broadcast();
  final _canonicalStarts = StreamController<DateTime>.broadcast();
  final _outcome = Completer<BioOutcome>();

  bool started = false;
  bool stopped = false;
  bool disposed = false;
  String? startedSessionId;

  @override
  Stream<BioReading> get readings => _readings.stream;

  @override
  Stream<DateTime> get canonicalStarts => _canonicalStarts.stream;

  @override
  Future<BioOutcome> get outcome => _outcome.future;

  @override
  Future<bool> isWatchReady() async => watchReady;

  @override
  Future<sh.WatchStatus?> watchStatus() async => sh.WatchStatus(
    supported: watchReady,
    reachable: watchReady,
    paired: watchReady,
    installed: watchReady,
  );

  @override
  Future<void> start({
    required String sessionId,
    required Duration planned,
    String windowLabel = 'focus',
  }) async {
    started = true;
    startedSessionId = sessionId;
    _canonicalStarts.add(DateTime.now());
  }


  void emit(BioReading reading) {
    if (!_readings.isClosed) _readings.add(reading);
  }

  @override
  Future<BioOutcome> stop(String sessionId) async {
    stopped = true;
    if (!_outcome.isCompleted) _outcome.complete(outcomeOnStop);
    return _outcome.future;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    if (!_outcome.isCompleted) {
      _outcome.complete(const BioOutcome(origin: SignalOrigin.unmeasured));
    }
    await _readings.close();
    await _canonicalStarts.close();
  }
}
