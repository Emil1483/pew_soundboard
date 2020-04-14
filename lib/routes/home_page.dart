import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../helpers/sound_data.dart';
import '../ui_elements/button.dart';
import '../ui_elements/submission_popup.dart';
import '../providers/app_data.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final int crossAxisCount = portrait ? 3 : 5;

    final AppData appData = Provider.of<AppData>(context);
    final List<SoundData> data = appData.data;
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: Text("PewDiePie Soundboard"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SubmissionPopup();
                },
              );
            },
          ),
        ],
      ),
      body: data.length > 0
          ? StaggeredGridView.countBuilder(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              itemCount: data.length + 1,
              crossAxisCount: crossAxisCount,
              staggeredTileBuilder: (int index) => StaggeredTile.fit(
                index < data.length ? 1 : crossAxisCount,
              ),
              itemBuilder: (BuildContext context, int index) =>
                  index < data.length
                      ? Button(soundData: data[index])
                      : SizedBox(
                          height: appData.adLoaded && !portrait ? 60.0 : 0.0,
                        ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
