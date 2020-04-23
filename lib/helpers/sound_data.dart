class SoundData {
  String url;
  final String name;
  final List<String> by;

  SoundData({
    this.url,
    this.name,
    this.by,
  });

  factory SoundData.fromJson(Map<String, dynamic> data) {
    List<String> by = [];
    dynamic byData = data["by"];
    if (byData != null) {
      (byData as List<dynamic>).forEach(
        (dynamic value) => by.add(value as String),
      );
    }
    return SoundData(
      url: data["url"],
      name: data["name"],
      by: by,
    );
  }
}
