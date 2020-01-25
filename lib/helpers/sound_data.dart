import 'package:flutter/material.dart';

class SoundData {
  String url;
  final String name;

  SoundData({
    @required this.url,
    @required this.name,
  });

  factory SoundData.fromJson(Map<String, dynamic> data) {
    return SoundData(
      url: data["url"],
      name: data["name"],
    );
  }
}
