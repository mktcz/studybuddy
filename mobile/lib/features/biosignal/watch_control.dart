import 'dart:convert';

import 'package:flutter/services.dart';


enum WatchControlAction {
  stop,
  pause,
  resume;

  static WatchControlAction? parse(String? raw) => switch (raw) {
    'stop' => WatchControlAction.stop,
    'pause' => WatchControlAction.pause,
    'resume' => WatchControlAction.resume,
    _ => null,
  };
}


class WatchControl {
  const WatchControl({required this.action, this.sessionId});

  final WatchControlAction action;


  final String? sessionId;

  static WatchControl? decode(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    final Object? json;
    try {
      json = jsonDecode(payload);
    } catch (_) {
      return null;
    }
    if (json is! Map<String, Object?>) return null;

    final action = WatchControlAction.parse(json['action'] as String?);
    if (action == null) return null;

    return WatchControl(
      action: action,
      sessionId: json['session_id'] as String?,
    );
  }
}


class WatchControlChannel {
  WatchControlChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('studybuddy/host');

  final MethodChannel _channel;

  void listen({
    required void Function(WatchControl control) onControl,
    void Function(Map<Object?, Object?> args)? onDebugCapture,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onWatchControl':
          final control = WatchControl.decode(call.arguments as String?);
          if (control != null) onControl(control);
        case 'onDebugCapture':
          final args = call.arguments;
          if (args is Map<Object?, Object?>) onDebugCapture?.call(args);
        default:
          break;
      }
      return null;
    });
  }


  Future<WatchControl?> takePending() async {
    try {
      final raw = await _channel.invokeMethod<String>(
        'takePendingWatchControl',
      );
      return WatchControl.decode(raw);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }


  Future<Map<Object?, Object?>?> takePendingDebugCapture() async {
    try {
      final value = await _channel.invokeMethod<Object?>('takePendingDebugCapture');
      if (value is Map) return Map<Object?, Object?>.from(value);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
    return null;
  }

  void dispose() => _channel.setMethodCallHandler(null);
}
