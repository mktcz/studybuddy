import 'package:flutter/services.dart';


class PickedPdf {
  const PickedPdf({
    required this.path,
    required this.name,
    required this.bytes,
  });


  final String path;


  final String name;

  final int bytes;
}


class PdfPicker {
  const PdfPicker();

  static const _channel = MethodChannel('studybuddy/host');


  Future<PickedPdf?> pick() async {
    final result = await _channel.invokeMapMethod<String, Object?>('pickPdf');
    if (result == null) return null;

    return PickedPdf(
      path: result['path']! as String,
      name: result['name'] as String? ?? 'Document',
      bytes: (result['bytes'] as num?)?.toInt() ?? 0,
    );
  }
}
