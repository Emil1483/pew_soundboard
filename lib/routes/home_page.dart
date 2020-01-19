import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../helpers/sound_data.dart';
import '../ui_elements/button.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Firestore _db = Firestore.instance;
  final AudioPlayer _player = AudioPlayer();

  final List<SoundData> _data = [];

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
      _data.add(_data[0]);
      _data.add(_data[0]);
      _data.add(_data[0]);
      _data.add(_data[0]);
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
        itemBuilder: (BuildContext context, int index) => Button(
          soundData: _data[index],
          audio: _player,
        ),
      ),
    );
  }
}
