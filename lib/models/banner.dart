class RedirectModel {
  final String id;
  final String name;
  final String image;
  final int totalTests;
  final int freeTests;

  RedirectModel({
    required this.id,
    required this.name,
    required this.image,
    required this.totalTests,
    required this.freeTests,
  });

  factory RedirectModel.fromJson(Map<String, dynamic> json) {
    return RedirectModel(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      totalTests: json['totalTests'],
      freeTests: json['freeTests'],
    );
  }
}

class Banner {
  final String id;
  final String type;
  final String url;
  final RedirectModel redirectId;
  final String redirectModel;

  Banner({
    required this.id,
    required this.type,
    required this.url,
    required this.redirectId,
    required this.redirectModel,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['_id'],
      type: json['type'],
      url: json['url'],
      redirectId: RedirectModel.fromJson(json['redirectId']),
      redirectModel: json['redirectModel'],
    );
  }
}
