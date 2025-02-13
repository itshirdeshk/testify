import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testify/providers/test_provider.dart';
import 'package:testify/providers/user_provider.dart';
import 'package:testify/views/test_series/test_series_detailed_screen.dart';
import 'package:testify/views/test_series/test_series_screen.dart';
import 'package:testify/widgets/custom_test_card.dart';
import 'package:testify/models/banner.dart' as banner_model;

class TestScreenMain extends StatefulWidget {
  const TestScreenMain({super.key});

  @override
  TestScreenMainState createState() => TestScreenMainState();
}

class TestScreenMainState extends State<TestScreenMain> {
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1000,
    );
    _startImageSlider();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.delayed(
        Duration.zero); // Wait for widget to be properly mounted
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final subExamId = userProvider.user?.subExamId;
    if (subExamId != null) {
      if (!mounted) return;
      await Provider.of<TestProvider>(context, listen: false)
          .fetchTestSeries(subExamId, context);
      if (!mounted) return;
      await Provider.of<TestProvider>(context, listen: false)
          .fetchBanners(subExamId, context);
    }
  }

  void _startImageSlider() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.toInt() + 1;
        if (nextPage >= 1000) {
          nextPage = 1000 ~/ 2;
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

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Widget _buildHeader() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).primaryColor.withOpacity(0.05),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: Theme.of(context).primaryColor.withOpacity(0.1),
  //       ),
  //     ),
  //     margin: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Your Test Progress',
  //           style: TextStyle(
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //             color: Theme.of(context).textTheme.bodyLarge?.color,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             _buildProgressItem(
  //               icon: Icons.check_circle_outline,
  //               value: '15',
  //               label: 'Completed',
  //               color: Colors.green,
  //             ),
  //             _buildProgressItem(
  //               icon: Icons.pending_outlined,
  //               value: '5',
  //               label: 'Pending',
  //               color: Colors.orange,
  //             ),
  //             _buildProgressItem(
  //               icon: Icons.trending_up,
  //               value: '85%',
  //               label: 'Accuracy',
  //               color: Theme.of(context).primaryColor,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildProgressItem({
  //   required IconData icon,
  //   required String value,
  //   required String label,
  //   required Color color,
  // }) {
  //   return Column(
  //     children: [
  //       Icon(icon, color: color, size: 28),
  //       const SizedBox(height: 8),
  //       Text(
  //         value,
  //         style: TextStyle(
  //           fontSize: 20,
  //           fontWeight: FontWeight.bold,
  //           color: color,
  //         ),
  //       ),
  //       Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: 12,
  //           color: color.withOpacity(0.8),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildUpcomingTests() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildSectionHeader('Upcoming Tests'),
  //       Container(
  //         height: 140,
  //         margin: const EdgeInsets.symmetric(horizontal: 16),
  //         child: ListView.builder(
  //           scrollDirection: Axis.horizontal,
  //           itemCount: 3,
  //           itemBuilder: (context, index) {
  //             return Container(
  //               width: 280,
  //               margin: const EdgeInsets.only(right: 16),
  //               child: Card(
  //                 color: Theme.of(context).cardColor,
  //                 elevation: 2,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(16),
  //                   side: BorderSide(
  //                     color: Theme.of(context).dividerColor,
  //                   ),
  //                 ),
  //                 child: InkWell(
  //                   onTap: () {},
  //                   borderRadius: BorderRadius.circular(16),
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
  //                                 color: Theme.of(context)
  //                                     .primaryColor
  //                                     .withOpacity(0.1),
  //                                 borderRadius: BorderRadius.circular(8),
  //                               ),
  //                               child: Icon(
  //                                 Icons.timer,
  //                                 color: Theme.of(context).primaryColor,
  //                               ),
  //                             ),
  //                             const SizedBox(width: 12),
  //                             Expanded(
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Text(
  //                                     'Mock Test 5',
  //                                     style: TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       fontSize: 16,
  //                                       color: Theme.of(context)
  //                                           .textTheme
  //                                           .bodyLarge
  //                                           ?.color,
  //                                     ),
  //                                     maxLines: 1,
  //                                     overflow: TextOverflow.ellipsis,
  //                                   ),
  //                                   Text(
  //                                     'Starting in 2 hours',
  //                                     style: TextStyle(
  //                                       color: Theme.of(context)
  //                                           .textTheme
  //                                           .bodyMedium
  //                                           ?.color!
  //                                           .withOpacity(0.7),
  //                                       fontSize: 12,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         const Spacer(),
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Expanded(
  //                               child: Text(
  //                                 '100 Questions • 2 Hours',
  //                                 style: TextStyle(
  //                                   color: Theme.of(context)
  //                                       .textTheme
  //                                       .bodyMedium
  //                                       ?.color!
  //                                       .withOpacity(0.7),
  //                                   fontSize: 12,
  //                                 ),
  //                               ),
  //                             ),
  //                             TextButton(
  //                               onPressed: () {},
  //                               child: const Text('Set Reminder'),
  //                             ),
  //                           ],
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
    final testProvider = Provider.of<TestProvider>(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => true,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          children: [
            // _buildHeader(),
            _buildImageSlider(testProvider.banners),
            // const SizedBox(height: 16),
            // _buildUpcomingTests(),
            // const SizedBox(height: 24),
            // if (_continueTests.isNotEmpty) ...[
            //   _buildSectionHeader('Enrolled Test Series'),
            //   ListView.builder(
            //     shrinkWrap: true,
            //     physics: const NeverScrollableScrollPhysics(),
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     itemCount: _continueTests.length,
            //     itemBuilder: (context, index) {
            //       final test = _continueTests[index];
            //       return Padding(
            //         padding: const EdgeInsets.only(bottom: 12),
            //         child: CustomTestCard(
            //           title: test['title'],
            //           imageUrl: test['image'],
            //           progress: test['completedTests'] / test['totalTests'],
            //           subtitle:
            //               '${test['completedTests']} of ${test['totalTests']} tests completed',
            //           onTap: () {
            //             // Handle enrolled test
            //           },
            //         ),
            //       );
            //     },
            //   ),
            // ],
            // _buildSectionHeader('New Test Series'),
            // SizedBox(
            //   height: 260,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     itemCount: _newTestSeries.length,
            //     itemBuilder: (context, index) {
            //       final test = _newTestSeries[index];
            //       return Container(
            //         width: 300,
            //         margin: const EdgeInsets.only(right: 16),
            //         child: Card(
            //           color: Theme.of(context).cardColor,
            //           elevation: 2,
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(16),
            //             side: BorderSide(
            //               color: Theme.of(context).dividerColor,
            //             ),
            //           ),
            //           child: InkWell(
            //             onTap: () {
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) => TestSeriesDetailScreen(
            //                     title: test['title'],
            //                     imageUrl: test['image'],
            //                     totalTests: test['totalTests'],
            //                     freeTests: test['freeTests'],
            //                     id: test['id'],
            //                   ),
            //                 ),
            //               );
            //             },
            //             borderRadius: BorderRadius.circular(16),
            //             child: Padding(
            //               padding: const EdgeInsets.all(16),
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Row(
            //                     children: [
            //                       ClipRRect(
            //                         borderRadius: BorderRadius.circular(12),
            //                         child: Image.asset(
            //                           test['image'],
            //                           height: 60,
            //                           width: 60,
            //                           fit: BoxFit.cover,
            //                         ),
            //                       ),
            //                       const SizedBox(width: 12),
            //                       Expanded(
            //                         child: Column(
            //                           crossAxisAlignment:
            //                               CrossAxisAlignment.start,
            //                           children: [
            //                             Text(
            //                               test['title'],
            //                               style: TextStyle(
            //                                 fontSize: 16,
            //                                 fontWeight: FontWeight.bold,
            //                                 color: Theme.of(context)
            //                                     .textTheme
            //                                     .bodyLarge
            //                                     ?.color,
            //                               ),
            //                               maxLines: 2,
            //                               overflow: TextOverflow.ellipsis,
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                   const SizedBox(height: 16),
            //                   Container(
            //                     padding: const EdgeInsets.symmetric(
            //                       horizontal: 12,
            //                       vertical: 6,
            //                     ),
            //                     decoration: BoxDecoration(
            //                       color: Theme.of(context)
            //                           .primaryColor
            //                           .withOpacity(0.1),
            //                       borderRadius: BorderRadius.circular(20),
            //                     ),
            //                     child: Text(
            //                       '${test['freeTests']} Free Tests Available',
            //                       style: TextStyle(
            //                         fontSize: 12,
            //                         color: Theme.of(context).primaryColor,
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                     ),
            //                   ),
            //                   const SizedBox(height: 12),
            //                   Row(
            //                     children: [
            //                       Icon(
            //                         Icons.assignment_outlined,
            //                         color: Theme.of(context)
            //                             .textTheme
            //                             .bodyMedium
            //                             ?.color
            //                             ?.withOpacity(0.7),
            //                         size: 16,
            //                       ),
            //                       const SizedBox(width: 4),
            //                       Text(
            //                         '${test['totalTests']} Total Tests',
            //                         style: TextStyle(
            //                           fontSize: 14,
            //                           color: Theme.of(context)
            //                               .textTheme
            //                               .bodyLarge
            //                               ?.color!
            //                               .withOpacity(0.7),
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                   const SizedBox(height: 8),
            //                   Row(
            //                     children: [
            //                       Icon(
            //                         Icons.language,
            //                         size: 16,
            //                         color: Theme.of(context)
            //                             .textTheme
            //                             .bodyLarge
            //                             ?.color!
            //                             .withOpacity(0.7),
            //                       ),
            //                       const SizedBox(width: 4),
            //                       Text(
            //                         test['languages'],
            //                         style: TextStyle(
            //                           fontSize: 14,
            //                           color: Theme.of(context)
            //                               .textTheme
            //                               .bodyLarge
            //                               ?.color!
            //                               .withOpacity(0.7),
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                   const SizedBox(
            //                     height: 5,
            //                   ),
            //                   const Spacer(),
            //                   SizedBox(
            //                     width: double.infinity,
            //                     child: ElevatedButton(
            //                       onPressed: () {
            //                         Navigator.push(
            //                           context,
            //                           MaterialPageRoute(
            //                             builder: (context) =>
            //                                 TestSeriesDetailScreen(
            //                               title: test['title'],
            //                               imageUrl: test['image'],
            //                               totalTests: test['totalTests'],
            //                               freeTests: test['freeTests'],
            //                               id: test['id'],
            //                             ),
            //                           ),
            //                         );
            //                       },
            //                       style: ElevatedButton.styleFrom(
            //                         backgroundColor:
            //                             Theme.of(context).primaryColor,
            //                         padding: const EdgeInsets.symmetric(
            //                             vertical: 12),
            //                         shape: RoundedRectangleBorder(
            //                           borderRadius: BorderRadius.circular(8),
            //                         ),
            //                       ),
            //                       child: const Text(
            //                         'Start Now',
            //                         style: TextStyle(
            //                           fontSize: 14,
            //                           fontWeight: FontWeight.bold,
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            // const SizedBox(height: 24),
            _buildSectionHeader(
              'Test Series for you',
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
                            ?.withOpacity(0.7),
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.assignment_outlined,
                                        size: 14,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${testSeries.totalTests} Tests',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
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
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
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
                                builder: (context) => TestSeriesDetailScreen(
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
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
              child: const Text('See All'),
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
                      ?.withOpacity(0.7),
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
                              color: Colors.black.withOpacity(0.1),
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
}
