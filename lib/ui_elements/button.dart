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

class _ButtonState extends State<Button> {
  bool _tapped = false;
  bool _justTapped = false;

  @override
  void initState() {
    super.initState();
    widget.audio.onAudioPositionChanged.listen((_) {
      if (_justTapped) return;
      setState(() => _tapped = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await widget.audio.stop();
        await widget.audio.play(widget.soundData.url);
        _justTapped = true;
        setState(() => _tapped = true);
        await Future.delayed(Duration(milliseconds: 100));
        _justTapped = false;
      },
      child: Container(
        color: _tapped ? Colors.orange : Colors.pink,
        margin: EdgeInsets.all(2.0),
        height: 100,
        child: Text(widget.soundData.name),
      ),
    );
  }
}
