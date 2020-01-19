import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../helpers/sound_data.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Firestore _db = Firestore.instance;

  final List<SoundData> _data = [];

  static final AudioPlayer _audio = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _getSounds();
  }

  void _getSounds() async {
    try {
      final ref = _db.collection("soundboard-data");
      final QuerySnapshot snap = await ref.getDocuments();
      for (DocumentSnapshot doc in snap.documents) {
        File file = await DefaultCacheManager().getSingleFile(
          doc.data["url"],
        );

        _data.add(
          SoundData(
            name: doc.data["name"],
            url: file.path,
          ),
        );
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

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
              await _audio.stop();
              print("playing: ${_data[index].url}");

              final String url = _data[index].url;

              await _audio.play(url);
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
