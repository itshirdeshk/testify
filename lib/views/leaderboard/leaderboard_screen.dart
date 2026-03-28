import 'package:flutter/material.dart';
import 'package:testify/models/leaderboard.dart';
import 'package:testify/services/score_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final String? testId;

  const LeaderboardScreen({
    super.key,
    this.testId,
  });

  @override
  LeaderboardScreenState createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLeaderboardLoading = true;
  List<Leaderboard> _leaderboard = [];
  late final ScoreService _scoreService;
  static const int _leaderboardPageSize = 10;
  bool _isLoadingMoreLeaderboard = false;
  bool _hasMoreLeaderboard = true;
  int _currentLeaderboardPage = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _initService();
  }

  Future<void> _initService() async {
    _scoreService = await ScoreService.create(context);
    await _fetchLeaderboard(reset: true);
  }

  Future<void> _fetchLeaderboard({bool reset = false}) async {
    if (reset) {
      if (mounted) {
        setState(() {
          _isLeaderboardLoading = true;
          _errorMessage = null;
          _currentLeaderboardPage = 1;
          _hasMoreLeaderboard = true;
        });
      }
    } else {
      if (_isLoadingMoreLeaderboard || !_hasMoreLeaderboard) return;
      if (mounted) {
        setState(() {
          _isLoadingMoreLeaderboard = true;
        });
      }
    }

    try {
      if (widget.testId == null || widget.testId!.isEmpty) {
        if (!mounted) return;
        setState(() {
          _leaderboard = [];
          _isLeaderboardLoading = false;
          _isLoadingMoreLeaderboard = false;
          _hasMoreLeaderboard = false;
        });
        return;
      }

      final nextPage = reset ? 1 : (_currentLeaderboardPage + 1);
      final leaderboard = await _scoreService.getLeaderboardPaginated(
        widget.testId!,
        page: nextPage,
        limit: _leaderboardPageSize,
      );

      if (mounted) {
        setState(() {
          _leaderboard = reset
              ? leaderboard.items
              : [..._leaderboard, ...leaderboard.items];
          _currentLeaderboardPage = leaderboard.pagination.currentPage;
          _hasMoreLeaderboard = leaderboard.pagination.hasNextPage;
          _isLeaderboardLoading = false;
          _isLoadingMoreLeaderboard = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (reset) {
            _leaderboard = [];
          }
          _errorMessage = 'Unable to load leaderboard right now.';
          _isLeaderboardLoading = false;
          _isLoadingMoreLeaderboard = false;
        });
      }
    }
  }

  Future<void> _loadMoreLeaderboard() async {
    await _fetchLeaderboard(reset: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Leaderboard',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Leaderboard'),
              ],
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.7),
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isLeaderboardLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildLeaderboardTab(_leaderboard),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(List<Leaderboard> leaderboard) {
    if (leaderboard.isEmpty && _errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    return Column(
      children: [
        Card(
          elevation: 2,
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.emoji_events_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Top Performers',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTopThree(
                  leaderboard.isNotEmpty ? leaderboard[0] : null,
                  leaderboard.length > 1 ? leaderboard[1] : null,
                  leaderboard.length > 2 ? leaderboard[2] : null,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Card(
            elevation: 2,
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            child: _buildLeaderboardList(leaderboard),
          ),
        ),
      ],
    );
  }

  Widget _buildTopThree(
      Leaderboard? first, Leaderboard? second, Leaderboard? third) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null)
            _buildTopUser(
              second.rank,
              second.user.name,
              second.user.profilePicture,
              double.parse(second.score.totalMarksObtained.toString()),
              double.parse(second.score.totalMarks.toString()),
            ),
          if (first != null)
            _buildTopUser(
              first.rank,
              first.user.name,
              first.user.profilePicture,
              double.parse(first.score.totalMarksObtained.toString()),
              double.parse(first.score.totalMarks.toString()),
            ),
          if (third != null)
            _buildTopUser(
              third.rank,
              third.user.name,
              third.user.profilePicture,
              double.parse(third.score.totalMarksObtained.toString()),
              double.parse(third.score.totalMarks.toString()),
            ),
        ],
      ),
    );
  }

  Widget _buildTopUser(int position, String name, String? profilePicure,
      double totalMarksObtained, double totalMarks) {
    final double height = position == 1 ? 120 : 100;
    final bool isFirst = position == 1;

    final sanitizedName = name.trim();
    final firstName = sanitizedName.isEmpty
      ? 'N/A'
      : sanitizedName.split(RegExp(r'\s+')).first;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ],
            ),
          ),
            child: profilePicure == null || profilePicure.trim().isEmpty
              ? CircleAvatar(
                  radius: isFirst ? 30 : 25,
                  backgroundColor: Colors.white,
                  child: Text(
                    position.toString(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: isFirst ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : CircleAvatar(
                  radius: isFirst ? 30 : 25,
                  backgroundImage: NetworkImage(profilePicure),
                ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.2),
                Theme.of(context).primaryColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                firstName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              Column(
                children: [
                  Text(
                    '$totalMarksObtained/$totalMarks',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Marks',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(List<Leaderboard> leaderboard) {
    final remainingParticipants = leaderboard.skip(3).toList();
    final shouldShowLoadMore = _hasMoreLeaderboard || _isLoadingMoreLeaderboard;

    if (remainingParticipants.isEmpty && !shouldShowLoadMore) {
      return Center(
        child: Text(
          'No participants found.',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: remainingParticipants.length + (shouldShowLoadMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= remainingParticipants.length) {
          if (_isLoadingMoreLeaderboard) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: OutlinedButton(
                onPressed: _hasMoreLeaderboard ? _loadMoreLeaderboard : null,
                child: const Text('Load More'),
              ),
            ),
          );
        }

        final participant = remainingParticipants[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${participant.rank}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            participant.user.name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${participant.score.totalMarksObtained}/${participant.score.totalMarks}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _fetchLeaderboard(reset: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
