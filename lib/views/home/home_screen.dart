import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testify/providers/test_provider.dart';
import 'package:testify/providers/user_provider.dart';
import 'package:testify/views/test_series/test_series_detailed_screen.dart';
import 'package:testify/views/test_series/test_series_screen.dart';
import 'package:testify/widgets/custom_test_card.dart';
import 'package:testify/models/banner.dart' as banner_model;
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late PageController _pageController;
  Timer? _timer;
  bool _isLoading = true;
  bool _isDataFetched = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1000, // Start at a large index
    );
    _startImageSlider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDataFetched) {
        // Check the flag
        _fetchData();
        _isDataFetched = true; // Set the flag to true
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final subExamId = userProvider.user?.subExamId;

    setState(() => _isLoading = true);

    try {
      final testProvider = Provider.of<TestProvider>(context, listen: false);

      // Call fetchTests first
      // await testProvider.fetchTests();

      // Parallel API calls for fetchTestSeries and fetchBanners
      if (subExamId != null && mounted) {
        await Future.wait([
          testProvider.fetchTestSeries(subExamId, context, forceRefresh: true),
          testProvider.fetchBanners(subExamId, context, forceRefresh: true),
        ]);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startImageSlider() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.toInt() + 1;
        if (nextPage >= 1000) {
          nextPage = 1000 ~/ 2; // Jump to the middle
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onBannerTap(banner_model.Banner banner) {
    if (banner.type == 'test-series') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestSeriesDetailScreen(
            title: banner.redirectId.name,
            imageUrl: banner.redirectId.image,
            totalTests: banner.redirectId.totalTests,
            freeTests: banner.redirectId.freeTests,
            id: banner.redirectId.id,
          ),
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0)),
              child: const Row(
                children: [
                  Text('See All'),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageSlider(List<banner_model.Banner> banners) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 180,
      child: banners.isEmpty
          ? Center(
              child: Text(
                'No Banners available',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
              ),
            )
          : PageView.builder(
              controller: _pageController,
              itemCount: banners.length * 1000,
              itemBuilder: (context, index) {
                final banner = banners[index % banners.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onBannerTap(banner),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            banner.url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 161, 161, 161),
      highlightColor: const Color.fromARGB(255, 214, 214, 214),
      child: Column(
        children: [
          // Shimmer for Welcome Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  height: 24,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          // Shimmer for Image Slider
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            height: 180,
          ),
          // Shimmer for Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 150,
                  height: 20,
                  color: Colors.white,
                ),
                Container(
                  width: 80,
                  height: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          // Shimmer for Test Series Cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 2,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Continue your preparation journey',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color!
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildQuickStats() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16),
  //     child: Row(
  //       children: [
  //         _buildStatCard(
  //           icon: Icons.assignment,
  //           title: 'Tests Taken',
  //           value: '12',
  //           color: Theme.of(context).primaryColor,
  //         ),
  //         const SizedBox(width: 12),
  //         _buildStatCard(
  //           icon: Icons.access_time,
  //           title: 'Hours Spent',
  //           value: '24',
  //           color: Theme.of(context).hintColor,
  //         ),
  //         const SizedBox(width: 12),
  //         _buildStatCard(
  //           icon: Icons.trending_up,
  //           title: 'Avg Score',
  //           value: '76%',
  //           color: Colors.green,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStatCard({
  //   required IconData icon,
  //   required String title,
  //   required String value,
  //   required Color color,
  // }) {
  //   return Expanded(
  //     child: Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         color: color.withValues(alpha:0.1),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: color.withValues(alpha:0.2)),
  //       ),
  //       child: Column(
  //         children: [
  //           Icon(icon, color: color, size: 24),
  //           const SizedBox(height: 8),
  //           Text(
  //             value,
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: color,
  //             ),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             title,
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: color.withValues(alpha:0.8),
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildRecommendedSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildSectionHeader('Recommended for You'),
  //       SizedBox(
  //         height: 180,
  //         child: ListView.builder(
  //           scrollDirection: Axis.horizontal,
  //           padding: const EdgeInsets.symmetric(horizontal: 16),
  //           itemCount: 3,
  //           itemBuilder: (context, index) {
  //             return Container(
  //               width: 300,
  //               margin: const EdgeInsets.only(right: 16),
  //               child: Card(
  //                 elevation: 4,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(16),
  //                     gradient: LinearGradient(
  //                       colors: [
  //                         Theme.of(context).primaryColor,
  //                         Theme.of(context).primaryColor.withValues(alpha:0.8),
  //                       ],
  //                     ),
  //                   ),
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(16),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Row(
  //                           children: [
  //                             Container(
  //                               padding: const EdgeInsets.all(8),
  //                               decoration: BoxDecoration(
  //                                 color: Colors.white.withValues(alpha:0.2),
  //                                 borderRadius: BorderRadius.circular(8),
  //                               ),
  //                               child: const Icon(
  //                                 Icons.star,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                             const SizedBox(width: 12),
  //                             const Expanded(
  //                               child: Text(
  //                                 'Daily Mock Test',
  //                                 style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontSize: 18,
  //                                   fontWeight: FontWeight.bold,
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         const SizedBox(height: 16),
  //                         const Text(
  //                           'Practice daily to improve your score',
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                         const Spacer(),
  //                         ElevatedButton(
  //                           onPressed: () {},
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.white,
  //                             foregroundColor: Theme.of(context).primaryColor,
  //                           ),
  //                           child: const Text('Start Now'),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(builder: (context, testProvider, child) {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) => true,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: _isLoading
              ? _buildShimmerEffect()
              : ListView(
                  children: [
                    _buildWelcomeHeader(),
                    _buildImageSlider(testProvider.banners),
                    // _buildQuickStats(),
                    // const SizedBox(height: 24),
                    // _buildRecommendedSection(),
                    // const SizedBox(height: 24),
                    // if (_continueTests.isNotEmpty) ...[
                    //   _buildSectionHeader('Continue Your Tests'),
                    //   ListView.builder(
                    //     shrinkWrap: true,
                    //     physics: const NeverScrollableScrollPhysics(),
                    //     itemCount: _continueTests.length,
                    //     itemBuilder: (context, index) {
                    //       final test = _continueTests[index];
                    //       return Padding(
                    //         padding:
                    //             const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    //         child: CustomTestCard(
                    //           title: test['title'],
                    //           imageUrl: test['image'],
                    //           progress: test['completedTests'] / test['totalTests'],
                    //           subtitle:
                    //               '${test['completedTests']} of ${test['totalTests']} tests completed',
                    //           onTap: () {
                    //             // Handle continue test
                    //           },
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ],
                    _buildSectionHeader(
                      'Test series for you',
                      onSeeAll: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TestSeriesScreen(
                            testSeries: testProvider.testSeries,
                          ),
                        ),
                      ),
                    ),
                    testProvider.testSeries.isEmpty
                        ? Center(
                            child: Text(
                              'No Test Series available',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: min(2, testProvider.testSeries.length),
                            itemBuilder: (context, index) {
                              final testSeries = testProvider.testSeries[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: CustomTestCard(
                                  title: testSeries.name,
                                  imageUrl: testSeries.image,
                                  details: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.assignment_outlined,
                                                size: 14,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${testSeries.totalTests} Tests',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.lock_open,
                                                size: 14,
                                                color: Colors.green,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${testSeries.freeTests} Free',
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  trailing: Icon(Icons.arrow_forward_ios,
                                      color: Theme.of(context).primaryColor),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TestSeriesDetailScreen(
                                          title: testSeries.name,
                                          imageUrl: testSeries.image,
                                          totalTests: testSeries.totalTests,
                                          freeTests: testSeries.freeTests,
                                          id: testSeries.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ],
                ),
        ),
      );
    });
  }
}

class Test {
  final String title;
  final int maxMarks;
  final int totalQuestions;

  Test({
    required this.title,
    required this.maxMarks,
    required this.totalQuestions,
  });
}
