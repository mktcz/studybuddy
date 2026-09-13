import '../state/hsi_engine.dart';
import 'bio_reading.dart';


extension WatchReadingSink on HumanStateGateway {
  void feedWatchReading(BioReading reading) {
    final bpm = reading.bpm;
    if (bpm != null && bpm.isFinite && bpm > 0) {
      pushHeartRate(reading.at, bpm, origin: reading.origin);
    }
    final rr = reading.rrIntervalMs;
    if (rr != null && rr.isFinite && rr > 0) {
      pushRr(reading.at, rr, origin: reading.origin);
    }
  }
}
