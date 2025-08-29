import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_theme.dart';
import 'base_mission_screen.dart';

class InteractiveQuizScreen extends BaseMissionScreen {
  const InteractiveQuizScreen({
    super.key,
    required super.mission,
    super.isPractice,
  });

  @override
  ConsumerState<BaseMissionScreen> createStateImpl() => _InteractiveQuizScreenState();
}

class _InteractiveQuizScreenState extends BaseMissionScreenState<InteractiveQuizScreen> {
  late final List<Map<String, dynamic>> _questions;
  int _currentQuestionIndex = 0;
  List<int> _userAnswers = [];
  bool _hasAnsweredCurrent = false;

  @override
  void initState() {
    super.initState();
    
    // Add null safety checks
    if (widget.mission.challenges.isNotEmpty) {
      final firstChallenge = widget.mission.challenges.first;
      if (firstChallenge.content.dataPayload != null && 
          firstChallenge.content.dataPayload['questions'] != null) {
        _questions = (firstChallenge.content.dataPayload['questions'] as List)
            .cast<Map<String, dynamic>>();
        _userAnswers = List.filled(_questions.length, -1);
      } else {
        // Fallback to empty questions if data structure is unexpected
        _questions = [];
        _userAnswers = [];
        print('Warning: Mission ${widget.mission.id} has unexpected data structure');
      }
    } else {
      // Fallback if no challenges
      _questions = [];
      _userAnswers = [];
      print('Warning: Mission ${widget.mission.id} has no challenges');
    }
  }

  @override
  Widget buildMissionContent() {
    // Check if we have questions to display
    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No questions available for this mission',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please contact support if this issue persists.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        _buildQuestionCard(),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: _buildAnswerOptions(),
          ),
        ),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildQuestionCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Safety check for current question index
    if (_currentQuestionIndex >= _questions.length) {
      return Container(
        margin: const EdgeInsets.all(AppTheme.spaceMedium),
        padding: const EdgeInsets.all(AppTheme.spaceLarge),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.cardShadow,
        ),
        child: const Center(
          child: Text('Question not available'),
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.all(AppTheme.spaceMedium),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMedium,
                    vertical: AppTheme.spaceSmall,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                    style: AppTheme.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spaceSmall),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    Icons.quiz_outlined,
                    color: AppTheme.accentBlue,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLarge),
            Text(
              _questions[_currentQuestionIndex]['question'] as String,
              style: AppTheme.getHeadlineSmall(isDark).copyWith(
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final options =
        (_questions[_currentQuestionIndex]['options'] as List).cast<String>();
    final correctAnswer = _questions[_currentQuestionIndex]['correct'] as int;

    return Column(
      children: List.generate(
        options.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMedium,
            vertical: AppTheme.spaceSmall,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: _hasAnsweredCurrent && index == correctAnswer
                  ? [
                      BoxShadow(
                        color: AppTheme.accentGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : _hasAnsweredCurrent && index == _userAnswers[_currentQuestionIndex] && index != correctAnswer
                      ? [
                          BoxShadow(
                            color: AppTheme.accentRed.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : AppTheme.cardShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _hasAnsweredCurrent
                    ? null
                    : () => _handleAnswerSelected(index),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spaceLarge),
                  decoration: BoxDecoration(
                    color: _getAnswerColor(index, correctAnswer),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: _hasAnsweredCurrent
                          ? (index == correctAnswer
                              ? AppTheme.accentGreen
                              : (index == _userAnswers[_currentQuestionIndex]
                                  ? AppTheme.accentRed
                                  : (isDark ? AppTheme.textLightDark : AppTheme.textLight)))
                          : (isDark ? AppTheme.textLightDark : AppTheme.textLight).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _hasAnsweredCurrent
                              ? (index == correctAnswer
                                  ? Colors.white
                                  : (index == _userAnswers[_currentQuestionIndex]
                                      ? Colors.white
                                      : (isDark ? AppTheme.textLightDark : AppTheme.textLight)))
                              : AppTheme.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D...
                            style: AppTheme.labelMedium.copyWith(
                              color: _hasAnsweredCurrent
                                  ? (index == correctAnswer
                                      ? AppTheme.accentGreen
                                      : (index == _userAnswers[_currentQuestionIndex]
                                          ? AppTheme.accentRed
                                          : Colors.white))
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceMedium),
                      Expanded(
                        child: Text(
                          options[index],
                          style: AppTheme.getBodyLarge(isDark).copyWith(
                            color: _hasAnsweredCurrent
                                ? (index == correctAnswer ||
                                        index == _userAnswers[_currentQuestionIndex]
                                    ? Colors.white
                                    : (isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight))
                                : (isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight),
                          ),
                        ),
                      ),
                      if (_hasAnsweredCurrent) ...[
                        const SizedBox(width: AppTheme.spaceSmall),
                        Icon(
                          index == correctAnswer
                              ? Icons.check_circle
                              : (index == _userAnswers[_currentQuestionIndex]
                                  ? Icons.cancel
                                  : null),
                          color: index == correctAnswer
                              ? Colors.white
                              : (index == _userAnswers[_currentQuestionIndex]
                                  ? Colors.white
                                  : null),
                          size: 24,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMedium),
      margin: const EdgeInsets.all(AppTheme.spaceMedium),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentQuestionIndex > 0)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.primaryPurple),
              ),
              child: ElevatedButton.icon(
                onPressed: _previousQuestion,
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text('Previous'),
                style: AppTheme.secondaryButtonStyle,
              ),
            )
          else
            const SizedBox(width: 100),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMedium,
              vertical: AppTheme.spaceSmall,
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Text(
              '${_currentQuestionIndex + 1} of ${_questions.length}',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.accentBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_currentQuestionIndex < _questions.length - 1)
            Container(
              decoration: BoxDecoration(
                gradient: _hasAnsweredCurrent ? AppTheme.primaryGradient : null,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: _hasAnsweredCurrent
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton.icon(
                onPressed: _hasAnsweredCurrent ? _nextQuestion : null,
                icon: const Icon(Icons.arrow_forward, size: 20),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasAnsweredCurrent ? Colors.transparent : (isDark ? AppTheme.textLightDark : AppTheme.textLight),
                  foregroundColor: _hasAnsweredCurrent ? Colors.white : Colors.white70,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            )
          else if (_hasAnsweredCurrent)
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.successGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _finishQuiz,
                icon: const Icon(Icons.check, size: 20),
                label: const Text('Finish'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 100),
        ],
      ),
    );
  }

  Color? _getAnswerColor(int optionIndex, int correctAnswer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (!_hasAnsweredCurrent) return isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;

    if (optionIndex == correctAnswer) {
      return AppTheme.accentGreen;
    }
    if (optionIndex == _userAnswers[_currentQuestionIndex]) {
      return AppTheme.accentRed;
    }
    return isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
  }

  void _handleAnswerSelected(int selectedIndex) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = selectedIndex;
      _hasAnsweredCurrent = true;
    });

    // Show feedback
    final isCorrect =
        selectedIndex == _questions[_currentQuestionIndex]['correct'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Text(
              isCorrect ? 'Correct!' : 'Incorrect. Try to remember this one!',
            ),
          ],
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _hasAnsweredCurrent = _userAnswers[_currentQuestionIndex] != -1;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _hasAnsweredCurrent = _userAnswers[_currentQuestionIndex] != -1;
      });
    }
  }

  void _finishQuiz() {
    final totalQuestions = _questions.length;
    int correctAnswers = 0;

    for (int i = 0; i < totalQuestions; i++) {
      if (_userAnswers[i] == _questions[i]['correct']) {
        correctAnswers++;
      }
    }

    final score = (correctAnswers / totalQuestions * 100).round();
    final passed = score >= 70; // 70% passing threshold

    if (passed) {
      completeMission();
      showSuccessAndExit();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Almost There!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.refresh,
                color: Colors.orange,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'You scored $score%. You need 70% to pass.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Review the questions you missed and try again!',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _currentQuestionIndex = 0;
                  _userAnswers = List.filled(_questions.length, -1);
                  _hasAnsweredCurrent = false;
                });
              },
              child: const Text('RETRY'),
            ),
          ],
        ),
      );
    }
  }

  @override
  double getProgressValue() {
    return (_currentQuestionIndex + (_hasAnsweredCurrent ? 1 : 0)) /
        _questions.length;
  }
}
