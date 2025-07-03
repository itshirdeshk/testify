import 'package:flutter/material.dart';
import 'package:testify/models/test.dart';

class TestCard extends StatelessWidget {
  final Test testInfo;
  final VoidCallback? onStart;
  final VoidCallback? onResult;
  final int? testNumber;
  final bool isPremium;

  const TestCard({
    super.key,
    required this.testInfo,
    this.onStart,
    this.onResult,
    this.testNumber,
    this.isPremium = false,
  });

  RoundedRectangleBorder _cardShape(BuildContext context) =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
      );

  BoxDecoration _iconContainerDecoration(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      );

  TextStyle _badgeTextStyle(Color color) => TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.bold,
      );

  Widget buildTestInfoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: _iconContainerDecoration(color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: _badgeTextStyle(color)),
        ],
      ),
    );
  }

  Widget _buildFreeTestCard(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: _cardShape(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildTestTitle(context),
            const SizedBox(height: 8),
            _buildTestStats(context),
            onResult != null
                ? Column(
                    children: [
                      const SizedBox(height: 14),
                      Divider(
                        height: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildResultButton(context),
                        ],
                      )
                    ],
                  )
                : const SizedBox(height: 0)
            // _buildLanguages(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedTestCard(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: _cardShape(context),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: _iconContainerDecoration(Theme.of(context).primaryColor),
          child: isPremium
              ? Icon(Icons.workspace_premium,
                  color: Colors.green.withValues(alpha: 0.1))
              : Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          testInfo.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle:
            isPremium ? _buildTestStats(context) : _buildTestSubtitle(context),
        trailing: isPremium
            ? _buildStartButton(context)
            : _buildUnlockButton(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildFreeTag(context),
        const Spacer(),
        _buildStartButton(context),
      ],
    );
  }

  Widget _buildFreeTag(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_open, size: 16, color: Colors.green),
          SizedBox(width: 4),
          Text(
            'FREE',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return TextButton.icon(
      onPressed: onStart,
      icon: const Icon(Icons.play_arrow),
      label:
          onResult == null ? const Text('Start Test') : const Text('Re Test'),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildResultButton(BuildContext context) {
    return TextButton.icon(
      onPressed: onResult,
      icon: const Icon(Icons.my_library_books_outlined),
      label: const Text('Show Result'),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildTestTitle(BuildContext context) {
    return Text(
      testInfo.title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildTestStats(BuildContext context) {
    return Row(
      children: [
        buildTestInfoBadge(
          Icons.help_outline,
          '${testInfo.totalQuestions} Qs',
          Colors.blue,
        ),
        const SizedBox(width: 12),
        buildTestInfoBadge(
          Icons.timer_outlined,
          '${testInfo.duration} mins',
          Colors.orange,
        ),
        const SizedBox(width: 12),
        buildTestInfoBadge(
          Icons.stars_outlined,
          '${testInfo.totalMarks} marks',
          Colors.green,
        ),
      ],
    );
  }

  // Widget _buildLanguages(BuildContext context) {
  //   return Row(
  //     children: [
  //       Icon(Icons.language,
  //           size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
  //       const SizedBox(width: 4),
  //       Text(
  //         testInfo.languages.join(', '),
  //         style: TextStyle(
  //           color: Theme.of(context).textTheme.bodyLarge?.color,
  //           fontSize: 14,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTestSubtitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '${testInfo.totalQuestions} Questions • ${testInfo.duration} mins • ${testInfo.totalMarks} Marks',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildUnlockButton(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
      ),
      child: const Text('Unlock'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return testNumber == null
        ? _buildFreeTestCard(context)
        : _buildLockedTestCard(context);
  }
}
