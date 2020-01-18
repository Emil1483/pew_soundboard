import 'package:flutter/material.dart';

import './routes/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pewdiepie Soundboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        canvasColor: Color(0xFF000000),
        accentColor: Color(0xFFF9013F),
        appBarTheme: AppBarTheme(
          color: Color(0xFFF9013F),
        ),
        textTheme: TextTheme(
          title: TextStyle(
            color: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.w900,
          )
        ),
      ),
      home: HomePage(),
    );
  }
}
