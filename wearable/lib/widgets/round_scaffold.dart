import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';


double roundInset(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide * 0.12;


class RoundScaffold extends StatelessWidget {
  const RoundScaffold({
    super.key,
    required this.child,
    this.bleed,
    this.padded = true,
  });

  final Widget child;


  final Widget? bleed;


  final bool padded;

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padded) {
      content = Padding(
        padding: EdgeInsets.all(roundInset(context)),


        child: Center(
          child: SingleChildScrollView(child: Center(child: child)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.sb.canvas,
      body: Stack(fit: StackFit.expand, children: [?bleed, content]),
    );
  }
}


class AmbientMode extends StatefulWidget {
  const AmbientMode({super.key, required this.builder});

  final Widget Function(BuildContext context, bool ambient) builder;

  @override
  State<AmbientMode> createState() => _AmbientModeState();
}

class _AmbientModeState extends State<AmbientMode> {
  static const _channel = MethodChannel('study_buddy/wear');

  bool _ambient = false;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_onCall);
  }

  Future<Object?> _onCall(MethodCall call) async {
    if (call.method != 'ambientChanged') return null;
    final ambient = call.arguments == true;
    if (mounted && ambient != _ambient) setState(() => _ambient = ambient);
    return null;
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _ambient);
}
