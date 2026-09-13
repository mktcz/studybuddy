import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/session_nudges.dart';
import '../../domain/study_logic.dart';

class WatchHsiRelay {
  const WatchHsiRelay({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('studybuddy/host');

  final MethodChannel _channel;


  static const _watchAxes = {'Focus', 'Capacity', 'Arousal', 'Stress'};

  Future<void> send(String sessionId, StateSample sample) async {
    try {
      await _channel.invokeMethod<void>('sendHsiToWatch', {
        'session_id': sessionId,
        'timestamp_ms': sample.at.millisecondsSinceEpoch,
        'hsi_version': sample.hsiVersion,
        'quality': sample.quality,
        'axes': {
          for (final entry in sample.availableAxes.entries)
            if (_watchAxes.contains(entry.key))
              entry.key.toLowerCase(): {
                'value': entry.value.value,
                'confidence': entry.value.confidence,
              },
        },
      });
    } on PlatformException {

    } on MissingPluginException {

    } catch (_) {

    }
  }

  Future<void> sendTimer({
    required String sessionId,
    required DateTime startedAt,
    required Duration planned,
    required Duration pausedTotal,
    DateTime? pausedSince,
  }) async {
    try {
      await _channel.invokeMethod<void>('sendTimerToWatch', {
        'session_id': sessionId,
        'started_at_ms': startedAt.millisecondsSinceEpoch,
        'planned_seconds': planned.inSeconds,
        'paused_seconds': pausedTotal.inSeconds,
        'paused_at_ms': pausedSince?.millisecondsSinceEpoch,
        'paused': pausedSince != null,
        'sent_at_ms': DateTime.now().millisecondsSinceEpoch,
      });
    } on PlatformException {

    } on MissingPluginException {

    } catch (_) {

    }
  }

  Future<void> sendNudge(String sessionId, Nudge nudge) async {
    try {
      await _channel.invokeMethod<void>('sendNudgeToWatch', {
        'session_id': sessionId,
        'kind': nudge.kind.name,
        'message': nudge.watchMessage,
        'at_ms': nudge.at.millisecondsSinceEpoch,
      });
    } on PlatformException {

    } on MissingPluginException {

    } catch (_) {

    }
  }
}

final watchHsiRelayProvider = Provider<WatchHsiRelay>(
  (ref) => const WatchHsiRelay(),
);
