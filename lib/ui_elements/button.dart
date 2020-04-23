import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../providers/app_data.dart';
import '../helpers/sound_data.dart';

class Button extends StatefulWidget {
  final SoundData soundData;
  final Function(SoundData) onLongPress;

  const Button({
    @required this.soundData,
    @required this.onLongPress,
  });

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> with TickerProviderStateMixin {
  bool _tapped = false;
  Duration _currentDuration = Duration();
  Timer _timer;

  AnimationController _controller;
  AnimationController _pressController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _forwardAnimation();

    _pressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 120),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AppData appData = Provider.of<AppData>(context, listen: false);

      appData.onPlayingSound.listen((String url) {
        if (url == widget.soundData.url) return;
        setState(() => _tapped = false);
      });

      appData.player.onDurationChanged.listen((Duration time) {
        if (_currentDuration != time) {
          _currentDuration = time;
          if (_timer != null) _timer.cancel();
          _timer = Timer(_currentDuration, () {
            if (mounted) setState(() => _tapped = false);
          });
        }
      });
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

  Future<void> _share() async {
    final AppData appData = Provider.of<AppData>(context, listen: false);
    appData.shareEvent(widget.soundData);
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
        onTapDown: (_) => _pressController.forward(from: 0),
        onTapUp: (_) => _pressController.value = 0,
        onTapCancel: () => _pressController.value = 0,
        onLongPress: () async {
          Feedback.forLongPress(context);
          //await _share();
          widget.onLongPress(widget.soundData);
        },
        onTap: () async {
          _currentDuration = null;

          // ↓↓↓

          final AppData appData = Provider.of<AppData>(context, listen: false);

          appData.buttonTap(widget.soundData.url);

          final AudioPlayer player = appData.player;

          await player.stop();
          await player.play(widget.soundData.url);

          // ↑↑↑
          // TODO: refactor this into appData.play(widget.soundData.url)

          setState(() => _tapped = true);
        },
        child: Container(
          margin: EdgeInsets.all(2.0),
          height: 120,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: AnimatedBuilder(
                  animation: _pressController,
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Image.asset(
                      _tapped ? "assets/face3.png" : "assets/face1.png",
                    ),
                  ),
                  builder: (_, Widget child) {
                    final double value = Curves.decelerate.transform(
                      _pressController.value,
                    );
                    final double size = 80 - value * 7;
                    return Container(
                      width: size,
                      alignment: Alignment.center,
                      child: Container(
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage("assets/pew-wall.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment(0, -0.5),
                  child: AutoSizeText(
                    widget.soundData.name,
                    style: Theme.of(context).textTheme.subtitle,
                    textAlign: TextAlign.center,
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
