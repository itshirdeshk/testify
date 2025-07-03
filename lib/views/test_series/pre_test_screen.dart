import 'package:flutter/material.dart';
import 'package:testify/models/test.dart';
import 'package:testify/services/test_service.dart';
import 'package:testify/views/result/result_screen.dart';
import 'package:testify/views/test_series/test_details_screen.dart';
import 'package:testify/widgets/test_cards/test_card.dart';

class PreTestScreen extends StatefulWidget {
  final String mockTestId;

  const PreTestScreen({
    super.key,
    required this.mockTestId,
  });

  @override
  PreTestScreenState createState() => PreTestScreenState();
}

class PreTestScreenState extends State<PreTestScreen> {
  bool _isLoading = false;
  final TestResponse _testResponse =
      TestResponse(unattemptedTests: [], attemptedTests: []);
  late final TestService _testService;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    _testService = await TestService.create(context);
    _fetchTests();
  }

  Future<void> _fetchTests() async {
    setState(() => _isLoading = true);
    try {
      final allTests = await _testService.getTests(widget.mockTestId);
      if (mounted) {
        setState(() {
          _testResponse.unattemptedTests = allTests.unattemptedTests;
          _testResponse.attemptedTests = allTests.attemptedTests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final freeTests =
        _testResponse.unattemptedTests!.where((test) => test.isFree).toList();
    final premiumTests =
        _testResponse.unattemptedTests!.where((test) => !test.isFree).toList();
    final previouslyAttemptedTests = _testResponse.attemptedTests!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  Expanded(
                    child: _buildFullTestTab(
                        freeTests, previouslyAttemptedTests, premiumTests),
                  ),
                  _buildUnlockButton(),
                ],
              ),
            ),
    );
  }

  // Widget _buildHeader() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     margin: const EdgeInsets.symmetric(horizontal: 16),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).primaryColor.withOpacity(0.05),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: Theme.of(context).primaryColor.withOpacity(0.1),
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           widget.testName,
  //           style: TextStyle(
  //             fontSize: 22,
  //             fontWeight: FontWeight.bold,
  //             color: Theme.of(context).textTheme.bodyLarge?.color,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           children: [
  //             _buildHeaderStat(
  //               Icons.help_outline,
  //               '${widget.questionCount}',
  //               'Questions',
  //               Colors.blue,
  //             ),
  //             const SizedBox(width: 16),
  //             _buildHeaderStat(
  //               Icons.timer_outlined,
  //               '${widget.duration}',
  //               'Minutes',
  //               Colors.orange,
  //             ),
  //             const SizedBox(width: 16),
  //             _buildHeaderStat(
  //               Icons.stars_outlined,
  //               '${widget.marks}',
  //               'Marks',
  //               Colors.green,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildHeaderStat(
  //     IconData icon, String value, String label, Color color) {
  //   return Expanded(
  //     child: Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         color: color.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: color.withOpacity(0.2)),
  //       ),
  //       child: Column(
  //         children: [
  //           Icon(icon, color: color, size: 24),
  //           const SizedBox(height: 8),
  //           Text(
  //             value,
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //               color: color,
  //             ),
  //           ),
  //           Text(
  //             label,
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: color.withOpacity(0.8),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildTabBar() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).cardColor,
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: TabBar(
  //       controller: _tabController,
  //       indicator: BoxDecoration(
  //         color: Theme.of(context).primaryColor,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       labelColor: Colors.white,
  //       unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
  //       tabs: [
  //         Tab(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               const Icon(Icons.assignment),
  //               const SizedBox(width: 8),
  //               Text('Full Test (Tier ${widget.marks > 100 ? "II" : "I"})'),
  //             ],
  //           ),
  //         ),
  //         const Tab(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Icon(Icons.category),
  //               SizedBox(width: 8),
  //               Text('Sectional'),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildFullTestTab(List<Test> freeTests,
      List<Test> previouslyAttemptedTests, List<Test> premiumTests) {
    return freeTests.isEmpty &&
            premiumTests.isEmpty &&
            previouslyAttemptedTests.isEmpty
        ? Center(
            child: Text(
              'No tests available',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          )
        : ListView(padding: const EdgeInsets.all(16), children: [
            if (freeTests.isNotEmpty) ...[
              Text(
                'Free Tests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              ...freeTests.map((test) => TestCard(
                    testInfo: test,
                    onStart: () => _navigateToTestDetails(test, false),
                  )),
              const SizedBox(height: 16),
              if (previouslyAttemptedTests.isNotEmpty) ...[
                Text(
                  'Previously Attempted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                ...previouslyAttemptedTests.map((test) => TestCard(
                      testInfo: test,
                      onStart: () => _navigateToTestDetails(test, true),
                      onResult: () => _navigateToResultScreen(test.id),
                    )),
                const SizedBox(height: 16),
              ],
              if (premiumTests.isNotEmpty) ...[
                Text(
                  'Premium Tests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                ...premiumTests.map((test) => TestCard(
                      testInfo: test,
                      onStart: () => _navigateToTestDetails(test, false),
                      testNumber: 1,
                    )),
              ],
              const SizedBox(height: 16),
            ]
          ]);
  }

  // Widget _buildLockedTestsList(List<Test> premiumTests) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Premium Tests',
  //         style: TextStyle(
  //           fontSize: 18,
  //           fontWeight: FontWeight.bold,
  //           color: Theme.of(context).textTheme.bodyLarge?.color,
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       ...List.generate(
  //         3,
  //         (index) => TestCard(
  //           testNumber: index + 1,
  //           testInfo: testInfo,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildUnlockButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => {},
        icon: const Icon(Icons.lock_open),
        label: const Text('Unlock All Tests'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  // Widget _buildSectionalTab() {
  //   return Center(
  //     child: Text(
  //       'Sectional Tests Coming Soon',
  //       style: TextStyle(
  //         fontSize: 16,
  //         color: Theme.of(context).textTheme.bodyMedium?.color,
  //       ),
  //     ),
  //   );
  // }

  void _navigateToTestDetails(Test test, bool isAttempted) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestDetailsScreen(
            testName: test.title,
            duration: test.duration,
            maxMarks: test.totalMarks,
            totalQuestions: test.totalQuestions,
            testId: test.id,
            isAttempted: isAttempted,
          ),
        ));
  }

  void _navigateToResultScreen(String testId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
            testId: testId,
            onClose: () {
              Navigator.pop(context);
              _fetchTests();
            }),
      ),
    );
  }
}
