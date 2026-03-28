import 'package:flutter/material.dart';
import 'package:testify/models/test_series.dart';
import 'package:testify/services/test_series_service.dart';
import 'package:testify/views/test_series/test_series_detailed_screen.dart';

class TestSeriesScreen extends StatefulWidget {
  final String subExamId;

  const TestSeriesScreen({
    super.key,
    required this.subExamId,
  });

  @override
  State<TestSeriesScreen> createState() => _TestSeriesScreenState();
}

class _TestSeriesScreenState extends State<TestSeriesScreen> {
  static const int _pageSize = 10;
  late final Future<TestSeriesService> _testSeriesServiceFuture;
  List<TestSeries> _testSeries = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreSeries = true;
  int _currentPage = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _testSeriesServiceFuture = TestSeriesService.create(context);
    _fetchTestSeries(reset: true);
  }

  Future<void> _fetchTestSeries({bool reset = false}) async {
    final subExamId = widget.subExamId.trim();

    if (subExamId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _testSeries = [];
        _isLoading = false;
        _isLoadingMore = false;
        _hasMoreSeries = false;
        _errorMessage = 'Please select an exam and sub-exam to view test series.';
      });
      return;
    }

    if (reset) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
          _currentPage = 1;
          _hasMoreSeries = true;
        });
      }
    } else {
      if (_isLoadingMore || !_hasMoreSeries) return;
      if (mounted) {
        setState(() {
          _isLoadingMore = true;
        });
      }
    }

    try {
      final service = await _testSeriesServiceFuture;
      final nextPage = reset ? 1 : (_currentPage + 1);
      final response = await service.getTestSeriesPaginated(
        subExamId,
        page: nextPage,
        limit: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _testSeries =
            reset ? response.items : <TestSeries>[..._testSeries, ...response.items];
        _currentPage = response.pagination.currentPage;
        _hasMoreSeries = response.pagination.hasNextPage;
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = 'Unable to load test series right now.';
      });
    }
  }

  Future<void> _loadMore() async {
    await _fetchTestSeries(reset: false);
  }

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildFilterSection(context),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildTestList(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Calculate total tests and free tests
    final totalTests = _testSeries.fold<int>(
      0,
      (sum, series) => sum + series.totalTests,
    );

    final totalFreeTests = _testSeries.fold<int>(
      0,
      (sum, series) => sum + series.freeTests,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Series',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose from our wide range of test series',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(
                'Available Tests',
                '$totalTests',
                Icons.assignment_outlined,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Free Tests',
                '$totalFreeTests',
                Icons.lock_open,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(context, 'All Tests', true),
          // _buildFilterChip(context, 'Popular', false),
          // _buildFilterChip(context, 'Latest', false),
          // _buildFilterChip(context, 'Free', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (bool value) {
          // Implement filter logic
        },
        backgroundColor: Theme.of(context).cardColor,
        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildTestList(BuildContext context) {
    if (_errorMessage != null && _testSeries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _fetchTestSeries(reset: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_testSeries.isEmpty) {
      return Center(
        child: Text(
          'No test series available',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _testSeries.length + ((_hasMoreSeries || _isLoadingMore) ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _testSeries.length) {
          if (_isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: OutlinedButton(
                onPressed: _hasMoreSeries ? _loadMore : null,
                child: const Text('Load More'),
              ),
            ),
          );
        }

        final testSeries = _testSeries[index];
        return Card(
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: InkWell(
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
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      testSeries.image,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 80,
                          width: 80,
                          color: Colors.grey[200],
                          child:
                              Icon(Icons.error_outline, color: Colors.grey[400]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          testSeries.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTestBadge(
                              context,
                              Icons.assignment_outlined,
                              '${testSeries.totalTests} Tests',
                              Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            _buildTestBadge(
                              context,
                              Icons.lock_open,
                              '${testSeries.freeTests} Free',
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestBadge(
      BuildContext context, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
