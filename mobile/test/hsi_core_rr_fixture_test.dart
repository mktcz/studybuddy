import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/features/biosignal/synthetic_beat_fixture.dart';
import 'package:studybuddy/features/state/hsi_engine.dart';
import 'package:synheart_core/synheart_core.dart';


void main() {
  test(
    'beat-timed HR+RR through native Core yields four positive-confidence axes',
    () async {
      final tmp = await Directory.systemTemp.createTemp('studybuddy_hsi_');
      addTearDown(() => tmp.delete(recursive: true));

      final bridge = CoreRuntimeBridge.create({
        'app_id': 'com.studybuddy.app',
        'subject_id': 'sub_rr_fixture',
        'mode': 'insight',
        'data_dir': tmp.path,
        'storage': {'enabled': true},
        'ingest': {'enabled': false, 'hsi': false, 'lab': false},
        'device_auth': {'enabled': false},
      });
      if (bridge == null) {
        markTestSkipped(
          'Native Synheart Core is not loadable on this host. '
          'Vendor synheart/vendor/runtime/<platform>/libsynheart_core_runtime '
          'or set the library on the loader path.',
        );
        return;
      }
      addTearDown(bridge.dispose);

      bridge.ensurePipeline();
      expect(bridge.startSession(), isNotNull);

      final windows = <String>[];
      var lastTickMs = 0;
      for (final beat in SyntheticBeatFixture(
        preset: 'focus',
        seed: 42,
      ).timedBeats(count: 280, startMs: 1_700_000_000_000)) {
        bridge.pushHr(beat.timestampMs, beat.bpm);
        bridge.pushRr(
          beat.timestampMs,
          beat.rrIntervalMs,
          provider: 'watch_sample',
        );
        if (lastTickMs == 0 || beat.timestampMs - lastTickMs >= 60 * 1000) {
          final json = bridge.tick(beat.timestampMs);
          if (json != null && json.isNotEmpty) windows.add(json);
          lastTickMs = beat.timestampMs;
        }
      }
      final tail = bridge.tick(lastTickMs + 60 * 1000);
      if (tail != null && tail.isNotEmpty) windows.add(tail);

      expect(
        windows,
        isNotEmpty,
        reason: 'Native Core produced no HSI windows from beat-timed HR+RR.',
      );

      var sawFourPositive = false;
      Object? lastAxes;
      for (final raw in windows) {
        final sample = stateSampleFromHsi(HSIState.fromJson(raw));
        lastAxes = sample.availableAxes;
        final axes = sample.availableAxes;
        if (const ['Focus', 'Capacity', 'Arousal', 'Stress'].every((name) {
          final axis = axes[name];
          return axis != null && axis.confidence > 0;
        })) {
          sawFourPositive = true;
          break;
        }
      }
      expect(
        sawFourPositive,
        isTrue,
        reason:
            'Native Core never emitted four axes with positive confidence. '
            'Last availableAxes=$lastAxes windows=${windows.length}.',
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
