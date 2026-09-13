import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:synheart_core/synheart_core.dart';
import 'package:uuid/uuid.dart';

class WearCoreStatus {
  const WearCoreStatus({required this.ready, this.version, this.error});

  final bool ready;
  final String? version;
  final String? error;
}


class WearCore {
  static const _appId = String.fromEnvironment('SYNHEART_APP_ID');
  static const _subjectKey = 'study_buddy_watch_subject_id';
  static const _storage = FlutterSecureStorage();

  bool _initialized = false;

  Future<WearCoreStatus> initialize() async {
    if (_appId.isEmpty) {
      return const WearCoreStatus(
        ready: false,
        error: 'Build the watch with the Synheart runtime configuration.',
      );
    }
    try {
      var subjectId = await _storage.read(key: _subjectKey);
      if (subjectId == null || subjectId.isEmpty) {
        subjectId = 'sb_watch_${const Uuid().v4()}';
        await _storage.write(key: _subjectKey, value: subjectId);
      }
      await Synheart.initialize(
        config: SynheartConfig(
          appId: _appId,
          subjectId: subjectId,
          appVersion: '1.0.0',
          appName: 'Study Buddy',
          category: 'Productivity',
          developer: 'Study Buddy',
          mode: SynheartMode.personal,
          wearConfig: const WearConfig(
            sampleRateHz: 1,
            enableCaching: true,
            enableHighFrequencyHrv: false,
          ),
          allowUnsignedCapabilities: kDebugMode,
        ),
        runtimeLogEnvFilter: kDebugMode ? 'warn' : null,
      );
      _initialized = true;
      final diagnostics = Synheart.runtimeDiagnostics(probeAll: true);
      final available = diagnostics['isAvailable'] == true;
      return WearCoreStatus(
        ready: available,
        version: diagnostics['version']?.toString(),
        error: available ? null : 'The native Synheart runtime did not load.',
      );
    } catch (error) {
      return WearCoreStatus(ready: false, error: error.toString());
    }
  }

  Future<void> dispose() async {
    if (_initialized) await Synheart.dispose();
    _initialized = false;
  }
}
