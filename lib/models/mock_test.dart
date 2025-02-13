class MockTest {
  final String id;
  final String name;
  final int totalTests;
  final int freeTests;
  final String testSeries;

  MockTest({
    required this.id,
    required this.name,
    required this.totalTests,
    required this.freeTests,
    required this.testSeries,
  });

  factory MockTest.fromJson(Map<String, dynamic> json) {
    return MockTest(
      id: json['_id'],
      name: json['name'],
      totalTests: json['totalTests'],
      freeTests: json['freeTests'],
      testSeries: json['testSeries'],
    );
  }
}
