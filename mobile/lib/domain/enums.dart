enum SignalOrigin {

  wearableReal,


  unmeasured,


  wearableSyntheticTest,
}


enum SyncState {
  localOnly,
  pending,
  syncing,
  synced,
  failed,
  offlineQueued,
  rejected,
}

enum CapturePhase { readiness, focus }


enum HeartRateQuality { high, medium, low, noContact, unreliable, unknown }

extension HeartRateQualityX on HeartRateQuality {

  bool get isUsable =>
      this == HeartRateQuality.high || this == HeartRateQuality.medium;

  static HeartRateQuality parse(String? raw) => switch (raw) {
    'high' => HeartRateQuality.high,
    'medium' => HeartRateQuality.medium,
    'low' => HeartRateQuality.low,
    'no_contact' => HeartRateQuality.noContact,
    'unreliable' => HeartRateQuality.unreliable,
    _ => HeartRateQuality.unknown,
  };
}


enum SessionStatus {

  planned,

  running,
  paused,


  completed,


  abandoned,
}

extension SessionStatusX on SessionStatus {
  bool get isActive =>
      this == SessionStatus.running || this == SessionStatus.paused;

  bool get isFinished =>
      this == SessionStatus.completed || this == SessionStatus.abandoned;
}
