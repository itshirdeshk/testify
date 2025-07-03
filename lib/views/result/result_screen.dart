import 'package:flutter/material.dart';
import 'package:testify/models/create_score.dart';
import 'package:testify/models/leaderboard.dart';
import 'package:testify/models/question.dart';
import 'package:testify/models/score.dart';
import 'package:testify/services/score_service.dart';

class ResultScreen extends StatefulWidget {
  final int? totalQuestions;
  final int? correctAnswers;
  final int? incorrectAnswers;
  final VoidCallback? onClose;
  final List<Question>? questions;
  final int? timeTaken;
  final String? testId;
  final bool? isAttempted;

  const ResultScreen(
      {super.key,
      this.totalQuestions,
      this.correctAnswers,
      this.incorrectAnswers,
      this.onClose,
      this.questions,
      this.timeTaken,
      this.testId,
      this.isAttempted});

  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isLeaderboardLoading = true;
  Score? _score;
  List<Leaderboard>? _leaderboard;
  late final ScoreService _scoreService;

  @override
  void initState() {
    super.initState();
    _tabController = (widget.testId != null &&
            widget.testId!.isNotEmpty &&
            widget.questions == null)
        ? TabController(length: 1, vsync: this)
        : TabController(length: 3, vsync: this);
    _initService();
  }

  Future<void> _initService() async {
    _scoreService = await ScoreService.create(context);
    if (widget.testId != null &&
        widget.testId!.isNotEmpty &&
        widget.questions == null) {
      _fetchScore();
    } else {
      _createOrUpdateScore();
    }
  }

  Future<void> _createOrUpdateScore() async {
    setState(() {
      _isLoading = true;
      _isLeaderboardLoading = true;
    });
    final CreateScore scoreData = CreateScore(
        testId: widget.testId!,
        totalQuestionsAttempted:
            (widget.correctAnswers! + widget.incorrectAnswers!),
        totalCorrect: widget.correctAnswers!,
        totalIncorrect: widget.incorrectAnswers!,
        timeTaken: widget.timeTaken!);
    try {
      final Score score;
      final List<Leaderboard> leaderboard;
      if (widget.isAttempted == true) {
        score = await _scoreService.updateScore(scoreData);
      } else {
        score = await _scoreService.createScore(scoreData);
      }

      if (mounted) {
        setState(() {
          _score = score;
          _isLoading = false;
        });
      }

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
          _isLoading = false;
          _isLeaderboardLoading = false;
        });
      }
    }
  }

  Future<void> _fetchScore() async {
    setState(() => _isLoading = true);
    try {
      final score = await _scoreService.fetchScore(widget.testId!);

      if (mounted) {
        setState(() {
          _score = score;
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showExtraTabs = widget.testId != null &&
        widget.testId!.isNotEmpty &&
        widget.questions != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: widget.onClose,
        ),
        title: Text(
          'Test Result',
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
              tabs: [
                const Tab(text: 'Analysis'),
                if (showExtraTabs) const Tab(text: 'Solutions'),
                if (showExtraTabs) const Tab(text: 'Leaderboard'),
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
          _buildAnalysisTab(),
          if (showExtraTabs) _buildSolutionsTab(),
          if (showExtraTabs)
            _isLeaderboardLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildLeaderboardTab(_leaderboard!, _score!),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    if (_isLoading || _score == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildRankCard(),
          const SizedBox(height: 12),
          _buildScoreCard(),
          const SizedBox(height: 12),
          _buildStatsCard(),
          _buildGeneralInfo(),
        ],
      ),
    );
  }

  Widget _buildRankCard() {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.05),
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Performance',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                //   decoration: BoxDecoration(
                //     color: Colors.green.withValues(alpha:0.1),
                //     borderRadius: BorderRadius.circular(20),
                //     border: Border.all(color: Colors.green.withValues(alpha:0.3)),
                //   ),
                //   child: const Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Icon(Icons.trending_up, color: Colors.green, size: 16),
                //       SizedBox(width: 4),
                //       Text(
                //         '+15%',
                //         style: TextStyle(
                //           color: Colors.green,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .shadowColor
                            .withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _score!.rank.toString(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'Your Rank',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      // Text(
                      //   'Out of ${_score!.testStats.totalParticipants}',
                      //   style: Theme.of(context).textTheme.bodySmall,
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRankStat('Total Participants',
                    _score!.testStats.totalParticipants.toString()),
                Container(
                  height: 40,
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                _buildRankStat('Percentage', "${_score!.percentage}%"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard() {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '${_score!.totalMarksObtained}/${_score!.totalMarks}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Divider(height: 32, color: Theme.of(context).dividerColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreStat(
                    'Average Score', _score!.testStats.averageScore.toString()),
                _buildScoreStat(
                    'Best Score', _score!.testStats.bestScore.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreStat(String label, String value) {
    return Column(
      children: [
        Icon(
          Icons.analytics_outlined,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSolutionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.questions!.length,
      itemBuilder: (context, index) {
        final question = widget.questions![index];
        return Card(
          elevation: 2,
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              backgroundColor: Theme.of(context).cardColor,
              collapsedBackgroundColor: Theme.of(context).cardColor,
              tilePadding: const EdgeInsets.all(16),
              childrenPadding: const EdgeInsets.all(16),
              expandedAlignment: Alignment.topLeft,
              title: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Q${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
              children: [
                ...question.options.asMap().entries.map((entry) {
                  final isSelected = question.selectedOption == entry.key;
                  final isCorrect = entry.value.isCorrect;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withValues(alpha: 0.1)
                          : (isSelected
                              ? Colors.red.withValues(alpha: 0.1)
                              : Theme.of(context).cardColor),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCorrect
                            ? Colors.green.withValues(alpha: 0.3)
                            : (isSelected
                                ? Colors.red.withValues(alpha: 0.3)
                                : Theme.of(context).dividerColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCorrect
                              ? Icons.check_circle_outline
                              : (isSelected
                                  ? Icons.cancel_outlined
                                  : Icons.radio_button_unchecked),
                          color: isCorrect
                              ? Colors.green
                              : (isSelected ? Colors.red : null),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: isCorrect || isSelected
                                  ? Theme.of(context).textTheme.bodyLarge?.color
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardTab(List<Leaderboard> leaderboard, Score score) {
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
        _buildUserRank(score),
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
                Theme.of(context).primaryColor.withValues(alpha: 0.7),
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
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
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

  Widget _buildUserRank(Score score) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
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
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).cardColor,
              child: Text(
                score.rank.toString(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your Position',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${score.totalMarksObtained}/${score.totalMarks} Marks',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Theme.of(context).primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Top 15%',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatRow(
                'Percentile', '${_score!.percentile.toStringAsFixed(2)}%'),
            Divider(
              height: 25,
              color: Theme.of(context).dividerColor,
            ),
            _buildStatRow(
                'Accuracy', '${_score!.accuracy.toStringAsFixed(1)}%'),
            Divider(
              height: 25,
              color: Theme.of(context).dividerColor,
            ),
            _buildStatRow('Time Taken', '${_score!.timeTaken} minutes'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                )),
        Text(value,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  Widget _buildGeneralInfo() {
    return Card(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Performance Analysis',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  Icons.check_circle_outline,
                  Colors.green,
                  'Correct',
                  _score!.totalCorrect.toString(),
                  Theme.of(context).cardColor,
                ),
                _buildInfoItem(
                  Icons.cancel_outlined,
                  Colors.red,
                  'Incorrect',
                  _score!.totalIncorrect.toString(),
                  Theme.of(context).cardColor,
                ),
                if (widget.testId != null &&
                    widget.testId!.isNotEmpty &&
                    widget.questions != null)
                  _buildInfoItem(
                    Icons.radio_button_unchecked,
                    Colors.orange,
                    'Unattempted',
                    (widget.totalQuestions! -
                            widget.correctAnswers! -
                            widget.incorrectAnswers!)
                        .toString(),
                    Theme.of(context).cardColor,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, Color color, String label, String value,
      Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
