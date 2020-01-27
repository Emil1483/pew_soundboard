import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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

  //TODO: add ads

  @override
  void initState() {
    super.initState();
    _getSounds();
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  void _getSounds() async {
    try {
      final ref = _db.collection("soundboard-data");
      final QuerySnapshot snap = await ref.getDocuments();

      setState(() {
        for (DocumentSnapshot doc in snap.documents) {
          _data.add(
            SoundData(
              name: doc.data["name"],
              url: doc.data["url"],
            ),
          );
        }
        _data.sort((SoundData sound1, SoundData sound2) {
          return sound1.name.toLowerCase().compareTo(sound2.name.toLowerCase());
        });
      });

      final Directory dir = await getApplicationDocumentsDirectory();
      for (SoundData soundData in _data) {
        final File file = File('${dir.path}/${soundData.name}.mp3');
        if (!await file.exists()) {
          http.Response response = await http.get(soundData.url);
          await file.writeAsBytes(response.bodyBytes, flush: true);
        }
        soundData.url = file.path;
      }

      bool dataContains(String name) {
        bool result = false;
        _data.forEach((SoundData soundData) {
          if ("${soundData.name}.mp3" == name) {
            result = true;
          }
        });
        return result;
      }

      dir
          .list(recursive: true, followLinks: false)
          .listen((FileSystemEntity entity) async {
        if (!entity.path.endsWith(".mp3")) return;
        final name = entity.path.split("/").last;
        if (dataContains(name)) return;

        await entity.delete();
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: Text("PewDiePie Soundboard"),
      ),
      body: _data.length > 0
          ? StaggeredGridView.countBuilder(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              itemCount: _data.length,
              crossAxisCount: portrait ? 3 : 5,
              staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
              itemBuilder: (BuildContext context, int index) => Button(
                soundData: _data[index],
                audio: _player,
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
