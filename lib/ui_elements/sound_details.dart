import 'package:flutter/material.dart';
import '../helpers/sound_data.dart';

class SoundDetail extends StatelessWidget {
  final SoundData soundData;

  SoundDetail({
    @required this.soundData,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            soundData.name,
            style: theme.title,
          ),
          Column(
            children: soundData.by.map((name) => Text(name)).toList(),
          ),
        ],
      ),
    );
  }
}
