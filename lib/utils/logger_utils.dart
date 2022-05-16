import 'package:loggy/loggy.dart';
import 'package:shake/shake.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_loggy/flutter_loggy.dart';

extension LoggerUtilExtension on BuildContext {
  void debug(dynamic s) => logDebug(s);

  void info(dynamic s) => logInfo(s);

  void warn(dynamic s) => logWarning(s);

  void error(dynamic s) => logError(s);
}

class Logger {
  void debug(dynamic s) => logDebug(s);

  void info(dynamic s) => logInfo(s);

  void warn(dynamic s) => logWarning(s);

  void error(dynamic s) => logError(s);
  Logger._();
  //TODO make context aware
  factory Logger.of(String context) {
    return Logger._();
  }
}

class LoggerOverlayWidget extends StatefulWidget {
  final LogicalKeyboardKey? enableKey;
  final LogicalKeyboardKey? disableKey;
  final Widget child;

  const LoggerOverlayWidget({
    Key? key,
    required this.child,
    this.enableKey = LogicalKeyboardKey.semicolon,
    this.disableKey = LogicalKeyboardKey.quoteSingle,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoggerOverlayWidget();
}

class _LoggerOverlayWidget extends State<LoggerOverlayWidget> {
  final FocusNode _focus = FocusNode();
  bool _showOverlay = false;
  late ShakeDetector _detector;

  @override
  Widget build(BuildContext context) => RawKeyboardListener(
        onKey: (key) {
          if (key.logicalKey == widget.enableKey && !_showOverlay) {
            setState(() => _showOverlay = true);
            context.debug('showing debug overlay');
          }
          if (key.logicalKey == widget.disableKey && _showOverlay) {
            setState(() => _showOverlay = false);
            context.debug('removing debug overlay');
          }
        },
        focusNode: _focus,
        child: Stack(
          children: [
            widget.child,
            if (_showOverlay)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white12,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: LoggyStreamWidget(),
                ),
              ),
          ],
        ),
      );


  @override
  void initState() {
    super.initState();
    _detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        setState(() {
          context.debug('shaking the overlay!');
          _showOverlay = !_showOverlay;
        });
      },
    );
  }

  @override
  void dispose() {
    _focus.dispose();
    _detector.stopListening();
    super.dispose();
  }
}
