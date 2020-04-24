import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

import '../helpers/sound_data.dart';
import '../providers/app_data.dart';

class SoundDetail extends StatelessWidget {
  final SoundData soundData;

  SoundDetail({
    @required this.soundData,
  });

  Widget _buildPersonCard(BuildContext context, {@required String name}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
        margin: EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 8.0,
        ),
        decoration: name == null
            ? null
            : BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: Theme.of(context).cardColor,
              ),
        child: name == null
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.person),
                  SizedBox(width: 6.0),
                  Expanded(
                    child: AutoSizeText(
                      name,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPersonCardRow(BuildContext context,
      {@required List<String> names}) {
    return Row(
      children: names.map(
        (String name) {
          return _buildPersonCard(
            context,
            name: name,
          );
        },
      ).toList(),
    );
  }

  Widget _buildSuggestedBy(BuildContext context) {
    if (soundData.by.isEmpty) {
      return Text(
        "An original sound",
        style: Theme.of(context).textTheme.body2,
      );
    }
    return Column(
      children: <Widget>[
        Text(
          "A sound suggested by:",
          style: Theme.of(context).textTheme.body2,
        ),
        SizedBox(height: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _getSeperatedNames(context).map((List<String> names) {
            return _buildPersonCardRow(
              context,
              names: names,
            );
          }).toList(),
        ),
      ],
    );
  }

  List<List<String>> _getSeperatedNames(BuildContext context) {
    final bool portrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    List<List<String>> result = List<List<String>>();
    final names = soundData.by;
    final width = portrait ? 2 : 3;
    for (int i = 0; i < names.length; i += width) {
      final to = (i + width).clamp(0, names.length);
      List<String> add = names.sublist(i, to);
      add.addAll(
        List.filled(width - add.length, null),
      );
      result.add(add);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.symmetric(horizontal: 26.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  constraints: BoxConstraints.loose(
                    Size(
                      MediaQuery.of(context).size.width - 122.0,
                      double.infinity,
                    ),
                  ),
                  child: AutoSizeText(
                    soundData.name,
                    style: theme.headline,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: 16.0),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    final AppData appData =
                        Provider.of<AppData>(context, listen: false);
                    appData.shareEvent(soundData);
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Divider(),
            _buildSuggestedBy(context),
            SizedBox(height: 76.0),
          ],
        ),
      ),
    );
  }
}
