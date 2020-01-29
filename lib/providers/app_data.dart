import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

import '../advert_ids.dart';
import '../helpers/sound_data.dart';

class AppData with ChangeNotifier {
  final Firestore _db = Firestore.instance;
  final List<SoundData> _data = [];
  final AudioPlayer _player = AudioPlayer();

  BannerAd _bannerAd;
  bool _adLoaded = false;

  bool get adLoaded => _adLoaded;
  List<SoundData> get data => List.from(_data);
  AudioPlayer get player => _player;

  AppData() {
    _getSounds();

    FirebaseAdMob.instance.initialize(
      appId: AdvertIds.appId,
    );
    _initAdBanner();

    _initNotifications();
  }

  @override
  dispose() async {
    super.dispose();
    _player.dispose();
    await _bannerAd.dispose();
  }

  void _getSounds() async {
    try {
      final ref = _db.collection("soundboard-data");
      final QuerySnapshot snap = await ref.getDocuments();

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
      notifyListeners();

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

  Future<void> _initNotifications() async {
    final FirebaseMessaging fb = FirebaseMessaging();
    fb.requestNotificationPermissions();
  }

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
    _bannerAd.listener = (MobileAdEvent event) {
      if (event == MobileAdEvent.loaded) {
        _adLoaded = true;
        notifyListeners();
      }
    };
    await _bannerAd.load();
    await _bannerAd.show(anchorType: AnchorType.bottom);
  }
}
