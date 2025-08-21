import 'package:flutter/material.dart';
import 'dart:async';

import 'package:testify/views/result/result_screen.dart';
import 'package:testify/models/question.dart';
import 'package:testify/services/question_service.dart';

class QuizScreen extends StatefulWidget {
  final String testName;
  final String testId;
  final int duration; // Duration in minutes
  final bool isAttempted;

  const QuizScreen({
    super.key,
    required this.testName,
    required this.testId,
    required this.duration,
    required this.isAttempted,
  });

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  final ValueNotifier<String> _timerNotifier = ValueNotifier<String>('');
  bool _isLoading = false;
  List<Question> _questions = [];
  late final QuestionService _questionService;
  int _currentQuestionIndex = 0;
  int _totalCorrect = 0;
  int _totalIncorrect = 0;
  late Timer timer;
  int? timeRemaining; // Make nullable to handle initial state

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    _questionService = await QuestionService.create(context);
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() => _isLoading = true);
    try {
      final questions = await _questionService.getQuestions(widget.testId);
      if (mounted) {
        setState(() {
          _questions = questions;
          timeRemaining = widget.duration * 60; // Convert minutes to seconds
          _isLoading = false;
          startTimer();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleAnswer(int selectedOption) {
    setState(() {
      if (_questions[_currentQuestionIndex].selectedOption == null) {
        if (_questions[_currentQuestionIndex]
            .options[selectedOption]
            .isCorrect) {
          _totalCorrect++;
        } else {
          _totalIncorrect++;
        }
      }
      _questions[_currentQuestionIndex].selectedOption = selectedOption;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _timerNotifier.dispose();
    super.dispose();
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    timer = Timer.periodic(oneSecond, (Timer timer) {
      if (timeRemaining! > 0) {
        setState(() {
          timeRemaining = timeRemaining! - 1;
          _updateTimerNotifier(); // Update the notifier
        });
      } else {
        timer.cancel();
        endQuiz();
      }
    });
  }

  void _updateTimerNotifier() {
    final minutes = (timeRemaining! ~/ 60);
    final seconds = (timeRemaining! % 60);
    _timerNotifier.value =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void endQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          totalQuestions: _questions.length,
          correctAnswers: _totalCorrect,
          incorrectAnswers: _totalIncorrect,
          questions: _questions,
          testId: widget.testId,
          timeTaken: widget.duration -
              (timeRemaining ?? 0) ~/ 60, // Convert seconds to minutes
          onClose: () {
            Navigator.pop(context);
          },
          isAttempted: widget.isAttempted,
        ),
      ),
    );
  }

  void moveToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      endQuiz();
    }
  }

  void moveToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void clearAnswer() {
    setState(() {
      _questions[_currentQuestionIndex].selectedOption = null;
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Exit Test',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to exit the test?',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your progress will not be saved if you exit now',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Exit Test'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).textTheme.bodyLarge?.color),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.testName,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    color: Colors.orange,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Questions Available',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'This test doesn\'t have any questions yet. Please contact your administrator or try again later.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final options = question.options;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).textTheme.bodyLarge?.color),
            onPressed: () => _onWillPop(),
          ),
        ),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: _buildQuestionSection(
                    question, options, _currentQuestionIndex),
              ),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            widget.testName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          // const SizedBox(height: 8),
          // Text(
          //   'General Intelligence and Reasoning',
          //   style: TextStyle(
          //     fontSize: 14,
          //     color: Theme.of(context)
          //         .textTheme
          //         .bodyMedium
          //         ?.color!
          //         .withValues(alpha:0.7),
          //   ),
          // ),
          const SizedBox(height: 16),
          _buildHeaderStats(),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Row(
      children: [
        _buildQuestionStat(),
        const SizedBox(width: 16),
        _buildTimerStat(),
        const SizedBox(width: 16),
        _buildMarkingStat(),
      ],
    );
  }

  Widget _buildQuestionStat() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            const Icon(Icons.help_outline, color: Colors.blue),
            const SizedBox(height: 4),
            Text(
              '${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              'Questions',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerStat() {
    final minutes = (timeRemaining! ~/ 60);
    final seconds = (timeRemaining! % 60);
    final isLowTime = timeRemaining! < 300; // Less than 5 minutes

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLowTime
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLowTime
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.orange.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.timer_outlined,
              color: isLowTime ? Colors.red : Colors.orange,
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isLowTime ? Colors.red : Colors.orange,
              ),
            ),
            Text(
              'Remaining',
              style: TextStyle(
                fontSize: 12,
                color: (isLowTime ? Colors.red : Colors.orange)
                    .withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkingStat() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+${_questions[_currentQuestionIndex].positiveMarks}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '-${_questions[_currentQuestionIndex].negativeMarks}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(
      Question question, List<Option> options, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Q${index + 1}. ${question.title}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: options.asMap().entries.map((entry) {
                int index = entry.key;
                Option option = entry.value;
                return _buildOptionCard(index, option);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index, Option option) {
    final isSelected =
        _questions[_currentQuestionIndex].selectedOption == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleAnswer(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavigationButton(
            'Previous',
            Icons.arrow_back,
            moveToPreviousQuestion,
            isOutlined: true,
          ),
          _buildNavigationButton(
            'Clear',
            Icons.clear,
            clearAnswer,
            isOutlined: true,
          ),
          if (_currentQuestionIndex == _questions.length - 1)
            _buildNavigationButton(
              'Submit',
              Icons.check_circle,
              _showSubmitConfirmation,
            )
          else
            _buildNavigationButton(
              'Next',
              Icons.arrow_forward,
              moveToNextQuestion,
            ),
        ],
      ),
    );
  }

  // Add these helper methods:
  int get _attemptedQuestions {
    return _questions.where((q) => q.selectedOption != null).length;
  }

  int get _unattemptedQuestions {
    return _questions.length - _attemptedQuestions;
  }

// Add the submit confirmation dialog method:
  Future<void> _showSubmitConfirmation() async {
    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Submit Exam',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to submit the exam?',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 24),
                _buildStatItem(
                  Icons.check_circle_outline,
                  'Attempted Questions',
                  _attemptedQuestions.toString(),
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                  Icons.cancel_outlined,
                  'Unattempted Questions',
                  _unattemptedQuestions.toString(),
                  Colors.red,
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<String>(
                  valueListenable: _timerNotifier,
                  builder: (context, timeString, child) {
                    return _buildStatItem(
                      Icons.timer_outlined,
                      'Time Remaining',
                      timeString,
                      timeRemaining! < 300 ? Colors.red : Colors.orange,
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                endQuiz();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isOutlined = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined
            ? Theme.of(context).cardColor
            : Theme.of(context).primaryColor,
        foregroundColor:
            isOutlined ? Theme.of(context).primaryColor : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: isOutlined
            ? BorderSide(color: Theme.of(context).primaryColor)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
