import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../helpers/sound_data.dart';
import '../ui_elements/button.dart';
import '../ui_elements/submission_popup.dart';
import '../ui_elements/sound_details.dart';
import '../providers/app_data.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const _PANEL_HEADER_HEIGHT = 256.0;
  static const _PANEL_OPENED_PADDING = 2.0;
  static const _PANEL_CLOSED_PADDING = 62.0;

  AnimationController _panelController;
  SoundData _currentSound;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
  }

  bool get isPanenVisible {
    final AnimationStatus status = _panelController.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _panelUp(SoundData data) {
    if (isPanenVisible) return;
    _panelController.forward();
    setState(() => _currentSound = data);
  }

  void _panelDown() {
    if (!isPanenVisible) return;
    _panelController.reverse();
  }

  Widget _buildAnimatedPanel(BoxConstraints constraints) {
    final height = constraints.biggest.height;
    final bool portrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final headerHeight = (portrait ? _PANEL_HEADER_HEIGHT : 0.0);
    final panelHeight = height - headerHeight;
    return AnimatedBuilder(
      animation: _panelController,
      child: SizedBox(
        height: panelHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: Stack(
              children: <Widget>[
                Material(
                  color: Theme.of(context).backgroundColor,
                  child: _currentSound != null
                      ? SoundDetail(
                          soundData: _currentSound,
                        )
                      : null,
                ),
                Align(
                  alignment: Alignment(portrait ? 0.0 : 0.8, 0.9),
                  child: FloatingActionButton(
                    onPressed: _panelDown,
                    child: Icon(Icons.arrow_downward),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      builder: (BuildContext context, Widget child) {
        final value = Curves.easeInOutCubic.transform(_panelController.value);
        final startingOffset = height + _PANEL_CLOSED_PADDING;
        final openPadding = portrait ? _PANEL_OPENED_PADDING : 0.0;
        final valueMultiplier =
            startingOffset - headerHeight - openPadding;
        return Transform.translate(
          offset: Offset(0, startingOffset - valueMultiplier * value),
          child: child,
        );
      },
    );
  }

  Widget _buildButtons() {
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final int crossAxisCount = portrait ? 3 : 5;
    final AppData appData = Provider.of<AppData>(context);
    final List<SoundData> data = appData.data;

    return data.length > 0
        ? StaggeredGridView.countBuilder(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            itemCount: data.length + 1,
            crossAxisCount: crossAxisCount,
            staggeredTileBuilder: (int index) => StaggeredTile.fit(
              index < data.length ? 1 : crossAxisCount,
            ),
            itemBuilder: (BuildContext context, int index) =>
                index < data.length
                    ? Button(
                        soundData: data[index],
                        onLongPress: _panelUp,
                      )
                    : SizedBox(
                        height: appData.adLoaded && !portrait ? 60.0 : 0.0,
                      ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: Text("PewDiePie Soundboard"),
        actions: <Widget>[
          if (portrait)
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
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragDown: (_) => _panelDown(),
                child: _buildButtons(),
              ),
              _buildAnimatedPanel(constraints),
            ],
          );
        },
      ),
    );
  }
}
