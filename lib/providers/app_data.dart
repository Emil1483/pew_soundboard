import 'dart:async';
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
  final StreamController<String> _onButtonTapped =
      StreamController<String>.broadcast();

  BannerAd _bannerAd;
  bool _adLoaded = false;

  bool get adLoaded => _adLoaded;
  List<SoundData> get data => List.from(_data);
  AudioPlayer get player => _player;
  Stream<String> get onPlayingSound => _onButtonTapped.stream;

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

  void buttonTap(String url) {
    _onButtonTapped.add(url);
  }

  Future<String> writeFile({String url, String name, Directory dir}) async {
    if (dir == null) dir = await getExternalStorageDirectory();
    final File file = File('${dir.path}/$name.mp3');
    if (!await file.exists()) {
      http.Response response = await http.get(url);
      await file.writeAsBytes(response.bodyBytes, flush: true);
    }
    return file.path;
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

      final Directory dir = await getExternalStorageDirectory();

      for (SoundData soundData in _data) {
        soundData.url = await writeFile(
          url: soundData.url,
          name: soundData.name,
          dir: dir,
        );
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
