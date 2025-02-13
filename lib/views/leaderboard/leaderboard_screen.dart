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
  List<Leaderboard>? _leaderboard;
  late final ScoreService _scoreService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _initService();
  }

  Future<void> _initService() async {
    _scoreService = await ScoreService.create(context);
    await _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLeaderboardLoading = true;
    });

    try {
      final List<Leaderboard> leaderboard;

      if (widget.testId != null && widget.testId!.isNotEmpty) {
        leaderboard = await _scoreService.getLeaderboard(widget.testId!);
        if (mounted) {
          setState(() {
            _leaderboard = leaderboard;
            _isLeaderboardLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLeaderboardLoading = false;
        });
      }
    }
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
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
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
                  ?.withOpacity(0.7),
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
              : _buildLeaderboardTab(_leaderboard!),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(List<Leaderboard> leaderboard) {
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
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
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

    final firstName = name.split(' ').first;

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
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: profilePicure == null
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
                Theme.of(context).primaryColor.withOpacity(0.2),
                Theme.of(context).primaryColor.withOpacity(0.05),
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
    return leaderboard.length < 4
        ? Center(
            child: Text(
              'No more participants.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: leaderboard.length > 3 ? leaderboard.length - 3 : 0,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${leaderboard[index + 3].rank}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  leaderboard[index + 3].user.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${leaderboard[index + 3].score.totalMarksObtained}/${leaderboard[index + 3].score.totalMarks}',
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
}
