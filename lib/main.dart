import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './routes/home_page.dart';
import './providers/app_data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppData(),
      child: MaterialApp(
        title: 'Pewdiepie Soundboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          canvasColor: Color(0xFF131313),
          accentColor: Color(0xFFF9013F),
          backgroundColor: Color(0xFF212121),
          cardColor: Color(0xFF303030),
          appBarTheme: AppBarTheme(
            color: Color(0xFFF9013F),
          ),
          textTheme: TextTheme(
            title: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.w900,
            ),
            headline: TextStyle(
              fontSize: 42.0,
              fontWeight: FontWeight.w200,
            ),
            subtitle: TextStyle(
              color: Colors.white,
            ),
            body1: TextStyle(
              fontSize: 22.0,
            ),
            body2: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        home: Column(
          children: <Widget>[
            Expanded(
              child: HomePage(),
            ),
            Builder(
              builder: (BuildContext context) {
                final bool portrait =
                    MediaQuery.of(context).orientation == Orientation.portrait;
                final bool adLoaded = Provider.of<AppData>(context).adLoaded;
                return SizedBox(height: adLoaded && portrait ? 60.0 : 0);
              },
            ),
          ],
        ),
      ),
    );
  }
}
