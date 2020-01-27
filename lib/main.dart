import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import './routes/home_page.dart';
import './advert_ids.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BannerAd _bannerAd;

  static const MobileAdTargetingInfo _targetingInfo = MobileAdTargetingInfo(
    keywords: [
      "pewdiepie",
      "youtube",
      "soundboard",
    ],
    childDirected: false,
    testDevices: <String>["3C2BACC3B6177D291D421EFA6B1DBCE3"],
  );

  Future<void> _initAdBanner() async {
    _bannerAd = BannerAd(
      adUnitId: AdvertIds.bannerId,
      size: AdSize.fullBanner,
      targetingInfo: _targetingInfo,
    );
    await _bannerAd.load();
    await _bannerAd.show(anchorType: AnchorType.bottom);
  }

  Future<void> _initNotifications() async {
    final FirebaseMessaging fb = FirebaseMessaging();
    fb.requestNotificationPermissions();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAdMob.instance.initialize(
      appId: AdvertIds.appId,
    );
    _initAdBanner();

    _initNotifications();

    return MaterialApp(
      title: 'Pewdiepie Soundboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        canvasColor: Color(0xFF131313),
        accentColor: Color(0xFFF9013F),
        appBarTheme: AppBarTheme(
          color: Color(0xFFF9013F),
        ),
        textTheme: TextTheme(
          title: TextStyle(
            color: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.w900,
          ),
          subtitle: TextStyle(
            color: Colors.white,
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
              bool portrait =
                  MediaQuery.of(context).orientation == Orientation.portrait;
              return SizedBox(height: portrait ? 60.0 : 0);
            },
          ),
        ],
      ),
    );
  }
}
