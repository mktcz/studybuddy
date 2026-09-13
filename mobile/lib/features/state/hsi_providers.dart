import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/study_logic.dart';
import '../focus/focus_controller.dart';
import 'hsi_engine.dart';


final hsiEngineProvider = Provider<HumanStateGateway>((ref) {
  final HumanStateGateway engine = HsiEngine();
  unawaited(engine.initialize());
  ref.onDispose(engine.dispose);
  return engine;
});


final hsiStatusProvider = StreamProvider<HsiStatus>((ref) {
  return ref.watch(hsiEngineProvider).statuses;
});

final integrationHealthProvider = FutureProvider<IntegrationHealth>((ref) {
  ref.watch(hsiStatusProvider);
  return ref.watch(hsiEngineProvider).health();
});

final ingestionStatusProvider = FutureProvider<IngestionSnapshot>((ref) {
  ref.watch(hsiStatusProvider);
  return ref.watch(hsiEngineProvider).ingestionStatus();
});


const _ambientShelfLife = Duration(minutes: 15);


final ambientStateProvider = StreamProvider<StateSample?>((ref) {
  final engine = ref.watch(hsiEngineProvider);


  Timer? expiry;
  ref.onDispose(() => expiry?.cancel());

  final controller = StreamController<StateSample?>();
  ref.onDispose(controller.close);

  void publish(StateSample? sample) {
    if (controller.isClosed) return;
    controller.add(sample);
    expiry?.cancel();
    if (sample != null) {
      expiry = Timer(_ambientShelfLife, () => publish(null));
    }
  }

  publish(_fresh(engine.latest));
  final sub = engine.states.listen(publish);
  ref.onDispose(sub.cancel);

  return controller.stream;
});

StateSample? _fresh(StateSample? sample) {
  if (sample == null) return null;
  final age = DateTime.now().difference(sample.at);
  return age > _ambientShelfLife ? null : sample;
}


final currentStateProvider = Provider<StateSample?>((ref) {
  final focus = ref.watch(focusControllerProvider);
  if (focus.isActive && focus.state != null) return focus.state;
  return ref.watch(ambientStateProvider).value;
});
