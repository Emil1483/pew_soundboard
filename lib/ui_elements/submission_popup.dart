import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';

class SubmissionPopup extends StatefulWidget {
  @override
  _SubmissionPopupState createState() => _SubmissionPopupState();
}

class _SubmissionPopupState extends State<SubmissionPopup>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _errorController;

  TextEditingController _textController;

  bool _loading = false;
  bool _hasText = false;
  bool _noInternet = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _errorController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _textController.dispose();
    _errorController.dispose();
  }

  void _onSend(BuildContext context) async {
    AppData appData = Provider.of<AppData>(context, listen: false);
    bool hasInternet = await appData.hasInternet();
    if (!hasInternet) {
      _errorController.fling(
        velocity: _errorController.isDismissed ? 1 : -1,
      );
      setState(() => _noInternet = true);
      await Future.delayed(Duration(seconds: 1));
      setState(() => _noInternet = false);
      return;
    }
    
    setState(() => _loading = true);
    await appData.sendSubmission(_textController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    _controller.forward();
    await Future.delayed(_controller.duration);
    Navigator.of(context).pop();
  }

  double _shake(double t) {
    return 10 * math.sin(t * math.pi) * math.sin(t * math.pi * 3);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: AlertDialog(
        backgroundColor: Theme.of(context).canvasColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("What should I add?"),
            SizedBox(height: 6.0),
            Text(
              "The developer can see what you send",
              style: Theme.of(context)
                  .textTheme
                  .subtitle
                  .copyWith(color: Colors.grey),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _textController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              style: Theme.of(context).textTheme.body1,
              onChanged: (String text) {
                if (text.isNotEmpty != _hasText) {
                  setState(() => _hasText = text.isNotEmpty);
                }
              },
            ),
            SizedBox(height: 16.0),
            _loading
                ? SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(),
                  )
                : AnimatedBuilder(
                    animation: _errorController,
                    builder: (BuildContext context, Widget child) {
                      return Transform.translate(
                        offset: Offset(_shake(_errorController.value), 0),
                        child: child,
                      );
                    },
                    child: FlatButton(
                      onPressed: !_hasText || _noInternet
                          ? null
                          : () => _onSend(context),
                      color: Theme.of(context).accentColor,
                      child: Text(_noInternet ? "Check your internet" : "Send"),
                    ),
                  ),
          ],
        ),
      ),
      builder: (BuildContext context, Widget child) {
        double value1 = _controller.value;
        double value2 = (_controller.value * 1.5 - 0.5).clamp(0.0, 1.0);
        double curve1 = Curves.easeInBack.transform(value1);
        double curve2 = Curves.easeInOutCubic.transform(value2);
        double offset = -curve1 * 256.0;
        double angle = curve2 * math.pi / 2;
        return Transform(
          transform: Matrix4.identity()
            ..rotateY(angle)
            ..translate(0.0, offset, 0.0),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}