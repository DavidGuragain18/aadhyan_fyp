import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/course/course_model.dart';
import '../../../model/course/course_test_model.dart';

class QuizReportScreen extends StatelessWidget {
  final CourseModel course;
  final List<CourseTestModel> testQuestions;
  final List<int?> userAnswers;
  final List<bool> questionResults;
  final int correctAnswers;
  final double progressPercentage;

  const QuizReportScreen({
    Key? key,
    required this.course,
    required this.testQuestions,
    required this.userAnswers,
    required this.questionResults,
    required this.correctAnswers,
    required this.progressPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalQuestions = testQuestions.length;
    final wrongAnswers = totalQuestions - correctAnswers;
    final isPassed = progressPercentage >= 70;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(totalQuestions, wrongAnswers, isPassed),
            _buildQuestionsList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Quiz Report',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: () {
            // TODO: Implement share functionality
            Get.snackbar(
              'Share',
              'Share functionality will be implemented soon',
              backgroundColor: Colors.blue,
              colorText: Colors.white,
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderSection(int totalQuestions, int wrongAnswers, bool isPassed) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            isPassed ? const Color(0xFF047857) : const Color(0xFFDC2626),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Course Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.book_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  course.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Score Display
          Icon(
            isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 64,
            color: Colors.white,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            isPassed ? 'Quiz Passed!' : 'Quiz Failed',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '${progressPercentage.toInt()}%',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '$correctAnswers out of $totalQuestions questions correct',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Statistics Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Correct',
                  correctAnswers.toString(),
                  Icons.check_circle_outline,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Wrong',
                  wrongAnswers.toString(),
                  Icons.cancel_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Total',
                  totalQuestions.toString(),
                  Icons.quiz_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Review',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your answers and see the correct solutions',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF64748B).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          ...testQuestions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildQuestionReviewCard(question, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuestionReviewCard(CourseTestModel testQuestion, int index) {
    final questionData = testQuestion.questions.isNotEmpty
        ? testQuestion.questions.first
        : CourseTestQuestion(question: '', options: [], correctAnswer: 0);
    
    final userAnswer = userAnswers[index];
    final correctAnswer = testQuestion.correctAnswer;
    final isCorrect = questionResults[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect 
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFEF4444).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isCorrect 
                  ? const Color(0xFF10B981).withOpacity(0.08)
                  : const Color(0xFFEF4444).withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCorrect ? 'Correct' : 'Incorrect',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                      if (testQuestion.title.isNotEmpty)
                        Text(
                          testQuestion.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Question Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionData.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Answer Options
                ...questionData.options.asMap().entries.map((entry) {
                  final optionIndex = entry.key;
                  final option = entry.value;
                  final isUserAnswer = userAnswer == optionIndex;
                  final isCorrectOption = correctAnswer == optionIndex;
                  
                  Color backgroundColor;
                  Color borderColor;
                  Color textColor;
                  Widget? trailingIcon;
                  
                  if (isCorrectOption) {
                    backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
                    borderColor = const Color(0xFF10B981);
                    textColor = const Color(0xFF047857);
                    trailingIcon = const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 20,
                    );
                  } else if (isUserAnswer && !isCorrect) {
                    backgroundColor = const Color(0xFFEF4444).withOpacity(0.1);
                    borderColor = const Color(0xFFEF4444);
                    textColor = const Color(0xFFDC2626);
                    trailingIcon = const Icon(
                      Icons.cancel,
                      color: Color(0xFFEF4444),
                      size: 20,
                    );
                  } else {
                    backgroundColor = const Color(0xFFF8FAFC);
                    borderColor = const Color(0xFFE2E8F0);
                    textColor = const Color(0xFF374151);
                  }
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isCorrectOption 
                                ? const Color(0xFF10B981)
                                : isUserAnswer && !isCorrect
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF94A3B8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + optionIndex),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) ...[
                          const SizedBox(width: 12),
                          trailingIcon,
                        ],
                      ],
                    ),
                  );
                }).toList(),
                
                // Answer Summary
                if (!isCorrect) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Explanation',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userAnswer != null
                                    ? 'Your answer: ${String.fromCharCode(65 + userAnswer)} - ${questionData.options[userAnswer]}'
                                    : 'You didn\'t select any answer',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Correct answer: ${String.fromCharCode(65 + correctAnswer)} - ${questionData.options[correctAnswer]}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF047857),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Get.back();
          Get.back(); // Go back to course screen
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.home_rounded, color: Colors.white),
        label: const Text(
          'Back to Course',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}