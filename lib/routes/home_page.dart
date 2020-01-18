import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: Card(
          margin: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset("assets/pew-wall.jpg", fit: BoxFit.cover),
              Align(
                alignment: Alignment(-0.8, 0.4),
                child: Text(
                  "PewDiePie Soundboard",
                  style: Theme.of(context).textTheme.title,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
