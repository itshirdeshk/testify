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
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      totalTests: (json['totalTests'] as num?)?.toInt() ?? 0,
      freeTests: (json['freeTests'] as num?)?.toInt() ?? 0,
    );
  }
}

class Banner {
  final String id;
  final String type;
  final String url;
  final RedirectModel? redirectId;
  final String redirectModel;

  Banner({
    required this.id,
    required this.type,
    required this.url,
    required this.redirectId,
    required this.redirectModel,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    final redirectData = json['redirectId'];

    return Banner(
      id: (json['_id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      redirectId: redirectData is Map<String, dynamic>
          ? RedirectModel.fromJson(redirectData)
          : null,
      redirectModel: (json['redirectModel'] ?? '').toString(),
    );
  }
}
