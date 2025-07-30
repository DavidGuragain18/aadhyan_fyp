import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/course/test_question_controller.dart';
import '../../../model/course/course_lesson_model.dart';
import '../../../model/course/lesson_test_question_model.dart';

class LessonTestQuizScreen extends StatefulWidget {
  const LessonTestQuizScreen({Key? key}) : super(key: key);

  @override
  State<LessonTestQuizScreen> createState() => _LessonTestQuizScreenState();
}

class _LessonTestQuizScreenState extends State<LessonTestQuizScreen>
    with TickerProviderStateMixin {
  final LessonTestQuestionController controller = Get.put(
    LessonTestQuestionController(),
  );
  final CourseLessonModel lesson = Get.arguments as CourseLessonModel;

  // Quiz state variables
  int currentQuestionIndex = 0;
  int? selectedAnswer;
  int correctAnswers = 0;
  bool isQuizCompleted = false;
  bool showResults = false;
  List<int?> userAnswers = [];
  List<bool> questionResults = [];

  // Animation controllers
  late AnimationController _progressAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    // Initialize quiz
    if (controller.lessonIdController.text.isEmpty) {
      controller.lessonIdController.text = lesson.id;
      controller.titleController.text = lesson.title;
      controller.fetchTestQuestions().then((_) {
        _initializeQuiz();
      });
    } else {
      _initializeQuiz();
    }
  }

  void _initializeQuiz() {
    if (controller.testQuestions.isNotEmpty) {
      userAnswers = List.filled(controller.testQuestions.length, null);
      questionResults = List.filled(controller.testQuestions.length, false);
      _slideAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  double get progressPercentage {
    if (controller.testQuestions.isEmpty) return 0.0;
    return (correctAnswers / controller.testQuestions.length) * 100;
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      selectedAnswer = answerIndex;
    });
  }

  void _nextQuestion() {
    if (selectedAnswer == null) return;

    // Store user answer
    userAnswers[currentQuestionIndex] = selectedAnswer;
    
    // Check if answer is correct
    final currentQuestion = controller.testQuestions[currentQuestionIndex];
    bool isCorrect = selectedAnswer == currentQuestion.correctAnswer;
    questionResults[currentQuestionIndex] = isCorrect;
    
    if (isCorrect) {
      correctAnswers++;
    }

    // Move to next question or show results
    if (currentQuestionIndex < controller.testQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
      
      // Update progress animation
      _progressAnimationController.animateTo(
        (currentQuestionIndex + 1) / controller.testQuestions.length,
      );
      
      // Slide animation for next question
      _slideAnimationController.reset();
      _slideAnimationController.forward();
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    setState(() {
      isQuizCompleted = true;
      showResults = true;
    });
    
    // Return progress percentage to previous screen
    Get.back(result: progressPercentage);
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswer = null;
      correctAnswers = 0;
      isQuizCompleted = false;
      showResults = false;
      userAnswers = List.filled(controller.testQuestions.length, null);
      questionResults = List.filled(controller.testQuestions.length, false);
    });
    
    _progressAnimationController.reset();
    _slideAnimationController.reset();
    _slideAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.hasError.value) {
          return _buildErrorState();
        }

        if (controller.testQuestions.isEmpty) {
          return _buildEmptyState();
        }

        if (showResults) {
          return _buildResultsScreen();
        }

        return _buildQuizContent();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        lesson.title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (!showResults && controller.testQuestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${currentQuestionIndex + 1}/${controller.testQuestions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading quiz questions...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.fetchTestQuestions,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.quiz_outlined,
                size: 50,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No questions available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This lesson doesn\'t have any quiz questions yet.',
              style: TextStyle(color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    final currentQuestion = controller.testQuestions[currentQuestionIndex];
    final questionData = currentQuestion.questions.isNotEmpty
        ? currentQuestion.questions.first
        : TestQuestion(question: '', options: []);

    return Column(
      children: [
        // Progress Bar
        _buildProgressBar(),
        
        // Question Content
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionCard(questionData),
                  const SizedBox(height: 20),
                  _buildAnswerOptions(questionData.options),
                ],
              ),
            ),
          ),
        ),
        
        // Next Button
        _buildNextButton(),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${currentQuestionIndex + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                '${((currentQuestionIndex / controller.testQuestions.length) * 100).toInt()}% Complete',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: currentQuestionIndex / controller.testQuestions.length,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                minHeight: 8,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(TestQuestion questionData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Question ${currentQuestionIndex + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            questionData.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(List<String> options) {
    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedAnswer == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectAnswer(index),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF6366F1).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF6366F1)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected 
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF374151),
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: selectedAnswer != null ? _nextQuestion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFE2E8F0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: selectedAnswer != null ? 2 : 0,
          ),
          child: Text(
            currentQuestionIndex < controller.testQuestions.length - 1
                ? 'Next Question'
                : 'Finish Quiz',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Results Header
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  progressPercentage >= 70 
                      ? const Color(0xFF10B981)
                      : progressPercentage >= 50
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFEF4444),
                  progressPercentage >= 70 
                      ? const Color(0xFF047857)
                      : progressPercentage >= 50
                          ? const Color(0xFFD97706)
                          : const Color(0xFFDC2626),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (progressPercentage >= 70 
                      ? const Color(0xFF10B981)
                      : progressPercentage >= 50
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFEF4444)).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  progressPercentage >= 70 
                      ? Icons.celebration_rounded
                      : progressPercentage >= 50
                          ? Icons.thumb_up_rounded
                          : Icons.refresh_rounded,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  progressPercentage >= 70 
                      ? 'Excellent!'
                      : progressPercentage >= 50
                          ? 'Good Job!'
                          : 'Keep Trying!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You scored ${progressPercentage.toInt()}%',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$correctAnswers out of ${controller.testQuestions.length} questions correct',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Correct',
                  correctAnswers.toString(),
                  const Color(0xFF10B981),
                  Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Wrong',
                  (controller.testQuestions.length - correctAnswers).toString(),
                  const Color(0xFFEF4444),
                  Icons.cancel_rounded,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _restartQuiz,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Take Quiz Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _completeQuiz,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Lesson'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}