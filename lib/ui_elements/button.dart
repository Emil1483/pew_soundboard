import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../helpers/sound_data.dart';

class Button extends StatefulWidget {
  final SoundData soundData;
  final AudioPlayer audio;

  const Button({
    @required this.soundData,
    @required this.audio,
  });

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> with SingleTickerProviderStateMixin {
  bool _tapped = false;
  bool _justTapped = false;
  Duration _currentDuration = Duration();
  Timer _timer;

  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _forwardAnimation();

    widget.audio.onDurationChanged.listen((Duration time) async {
      if (_currentDuration != time) {
        _currentDuration = time;
        if (_justTapped) {
          if (_timer != null) _timer.cancel();
          _timer = Timer(_currentDuration, () {
            setState(() => _tapped = false);
          });
        } else {
          setState(() => _tapped = false);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) _timer.cancel();
    _controller.dispose();
  }

  void _forwardAnimation() async {
    await Future.delayed(Duration(milliseconds: 200));
    if (!mounted) return;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          _currentDuration = null;

          await widget.audio.stop();
          await widget.audio.play(widget.soundData.url);

          _justTapped = true;
          setState(() => _tapped = true);
          await Future.delayed(Duration(milliseconds: 100));
          _justTapped = false;
        },
        child: Container(
          margin: EdgeInsets.all(2.0),
          height: 120,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                  width: 80,
                  alignment: Alignment.center,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/pew-wall.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Image.asset(
                          _tapped ? "assets/face3.png" : "assets/face1.png"),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment(0, -0.5),
                  child: Text(
                    widget.soundData.name,
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
