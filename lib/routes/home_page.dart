import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:audioplayers/audioplayers.dart';

import '../helpers/sound_data.dart';

class HomePage extends StatelessWidget {
  final List<SoundData> _data = [
    SoundData(
      name: "big wav",
      url: "https://www.kozco.com/tech/LRMonoPhase4.wav",
    ),
    SoundData(
      name: "mp3",
      url:
          "https://firebasestorage.googleapis.com/v0/b/pew-soundboard.appspot.com/o/oof-low.mp3?alt=media&token=322b8fbd-5314-4914-9ede-351949228813",
    ),
    SoundData(
      name: "wav",
      url:
          "https://firebasestorage.googleapis.com/v0/b/pew-soundboard.appspot.com/o/oof.wav?alt=media&token=e6e0ad72-91e0-49a5-8f53-9256a4a5be14",
    ),
    SoundData(
      name: "mp3 asset",
      url: "assets/oof-low.mp3",
    ),
    SoundData(
      name: "wav asset",
      url: "assets/oof.wav",
    ),
    SoundData(
      name: "test6",
      url: "gs://pew-soundboard.appspot.com/oof.wav",
    ),
    SoundData(
      name: "test7",
      url: "gs://pew-soundboard.appspot.com/oof.wav",
    ),
    SoundData(
      name: "test8",
      url: "gs://pew-soundboard.appspot.com/oof.wav",
    ),
  ];

  final AudioPlayer _audio = new AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: Text("PewDiePie SoundBoard"),
      ),
      body: StaggeredGridView.countBuilder(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: _data.length,
        crossAxisCount: 3,
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {
              print("playing: ${_data[index].url}");
              await _audio.stop();
              await _audio.play(_data[index].url);
            },
            child: Container(
              color: Colors.orange,
              margin: EdgeInsets.all(2.0),
              height: 100,
              child: Text(_data[index].name),
            ),
          );
        },
      ),
    );
  }
}
