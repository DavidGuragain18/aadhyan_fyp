import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utility/clear_focus.dart';
import '../../../core/utility/dialog_utils.dart';
import '../../../core/utility/snackbar.dart';
import '../../model/api_response_model.dart';
import '../../model/course/course_test_model.dart';
import '../../services/course_test_services.dart';
import '../miscalleneous/notification_controller.dart';

class CourseTestController extends GetxController {
  // Observable lists and variables
  final RxList<CourseTestModel> testQuestions = <CourseTestModel>[].obs;
  final Rx<CourseTestModel?> selectedTestQuestion = Rx<CourseTestModel?>(null);
  final RxList<int> selectedCorrectAnswers = <int>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isFetchingById = false.obs;

  // Form controllers for create/update
  final TextEditingController titleController =
      TextEditingController(); // Overall test title
  final TextEditingController courseIdController = TextEditingController();
  final RxList<TextEditingController> questionControllers =
      <TextEditingController>[].obs;
  final RxList<TextEditingController>
  questionTitleControllers = // Individual question titles
      <TextEditingController>[].obs;
  final RxInt selectedCorrectAnswer = 0.obs;

  // Error handling
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeQuestionControllers();
    // fetchTestQuestions();
  }

  @override
  void onClose() {
    titleController.dispose();
    courseIdController.dispose();
    _disposeQuestionControllers();
    super.onClose();
  }

  // Initialize question controllers (default 1 question)
  void _initializeQuestionControllers() {
    questionControllers.clear();

    questionControllers.add(TextEditingController());

    selectedCorrectAnswers.clear();
    selectedCorrectAnswers.add(0);
  }

  // Dispose question controllers
  void _disposeQuestionControllers() {
    for (var controller in questionControllers) {
      controller.dispose();
    }
    questionControllers.clear();
  }

  // Add a new question field
  void addQuestion() {
    if (questionControllers.length < 10) {
      questionControllers.add(TextEditingController());
      selectedCorrectAnswers.add(0);
    }
  }

  // Remove a question field
  void removeQuestion(int index) {
    if (questionControllers.length > 1 && index < questionControllers.length) {
      questionControllers[index].dispose();
      questionControllers.removeAt(index);
      selectedCorrectAnswers.removeAt(index);

      if (selectedCorrectAnswer.value >= questionControllers.length) {
        selectedCorrectAnswer.value = questionControllers.length - 1;
      }
    }
  }

  // Fetch all test questions
  Future<void> fetchTestQuestions() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      await Future.delayed(Duration(seconds: 2));
      log(
        'Fetching test questions for course ID: ${courseIdController.text.trim()}',
      );

      final ApiResponse<List<CourseTestModel>> response =
          await CourseTestServices.getTestQuestionList(
            courseId: courseIdController.text.trim(),
          );

      if (response.success && response.data != null) {
        testQuestions.value = response.data!;
        log('Fetched ${testQuestions.length} test questions successfully');
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        log('Failed to fetch test questions: ${response.message}');
        SnackBarMessage.showErrorMessage(
          'Failed to load test questions: ${response.message}',
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      log('Error fetching test questions: $e');
      SnackBarMessage.showErrorMessage(
        'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch test question by ID
  Future<void> fetchTestQuestionById(String testId) async {
    try {
      isFetchingById.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final ApiResponse<CourseTestModel> response =
          await CourseTestServices.getTestQuestionById(
            courseId: courseIdController.text.trim(),
            testId: testId,
          );

      if (response.success && response.data != null) {
        selectedTestQuestion.value = response.data!;
        log(
          'Fetched test question by ID successfully: ${response.data!.title}',
        );
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        log('Failed to fetch test question by ID: ${response.message}');
        SnackBarMessage.showErrorMessage(
          'Failed to load test question ${response.message}',
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred';
      log('Error fetching test question by ID: $e');
      SnackBarMessage.showErrorMessage('An unexpected error occurred');
    } finally {
      isFetchingById.value = false;
    }
  }

  // Create a new test question
  Future<bool> createTestQuestion({List<List<String>>? optionsList}) async {
    ClearFocus.clearAllFocus;
    final shouldCreate = await DialogUtils.showConfirmDialog(
      title: 'Create Lesson Test',
      message: 'Are you sure you want to create this lesson test?',
      confirmText: 'Create',
      cancelText: 'Cancel',
      icon: Icons.add_circle,
    );

    if (!shouldCreate) return false;

    try {
      DialogUtils.showLoadingDialog(message: 'Creating lesson test...');
      await Future.delayed(const Duration(seconds: 2));

      isCreating.value = true;
      hasError.value = false;
      errorMessage.value = '';

      if (!_validateForm()) {
        DialogUtils.hideDialog();
        return false;
      }

      // Build questions with their respective options and titles
      List<CourseTestQuestion> questions = [];
      for (int i = 0; i < questionControllers.length; i++) {
        final questionText = questionControllers[i].text.trim();
        final options = optionsList?[i] ?? [];
        questions.add(
          CourseTestQuestion(
            question: questionText,
            options: options,
            correctAnswer: selectedCorrectAnswers[i],
          ),
        );
      }

      if (questions.isEmpty || questions.any((q) => q.options.isEmpty)) {
        errorMessage.value = 'Each question must have at least one option';
        DialogUtils.hideDialog();
        return false;
      }

      final correctAnswer = selectedCorrectAnswers[0];

      // Check if any question has empty options
      bool hasEmptyOptions = questions.any((q) => q.options.isEmpty);
      if (hasEmptyOptions) {
        errorMessage.value = 'All questions must have at least one option';
        DialogUtils.hideDialog();
        return false;
      }

      // Validate correct answer index
      if (selectedCorrectAnswer.value < 0 ||
          selectedCorrectAnswer.value >= questions.length) {
        errorMessage.value = 'Please select a valid correct answer';
        DialogUtils.hideDialog();
        return false;
      }

      log('Creating test question with data:');
      log('Title: ${titleController.text.trim()}');
      log('Lesson ID: ${courseIdController.text.trim()}');
      log('Questions count: ${questions.length}');
      log('Correct Answer Index: ${selectedCorrectAnswer.value}');
      for (int i = 0; i < questions.length; i++) {
        log('Question ${i + 1}: ${questions[i].question}');
        log('Options: ${questions[i].options.join(", ")}');
      }

      final ApiResponse<CourseTestModel> response =
          await CourseTestServices.createTestQuestion(
            courseId: courseIdController.text.trim(),
            title: titleController.text.trim(),
            questions: questions,
            correctAnswer: correctAnswer,
          );

      DialogUtils.hideDialog(); // Hide loading dialog

      if (response.success && response.data != null) {
        testQuestions.add(response.data!);

        try {
          log('Creating test notification...');
          final NotificationController notificationController = Get.put(
            NotificationController(),
          );
          await notificationController.createTestNotification(
            recipients: [],
            title: "New Course Update for ${titleController.text.trim()}",
            body: "A new lesson test has been added to your course",
            courseId: courseIdController.text.trim(),
          );
        } catch (e) {
          log('Error creating test notification: $e');
          SnackBarMessage.showErrorMessage(
            'Test question created, but failed to send notification: $e',
          );
        }

        clearForm();
        SnackBarMessage.showSuccessMessage(
          'Test question created successfully',
        );

        // 🎯 BEST PLACE: Navigate back after successful creation
        // Give user time to see the success message, then navigate back
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.back();

        return true;
      } else {
        log('❌ Failed to create test question: ${response.message}');
        SnackBarMessage.showErrorMessage(
          'Failed to create test question: ${response.message}',
        );

        // Option: You could also navigate back on failure if desired
        // Uncomment the line below if you want to go back even on failure
        // Get.back();

        return false;
      }
    } catch (e, stackTrace) {
      DialogUtils.hideDialog();
      log('❌ Error creating test question: $e');
      log('Stack trace: $stackTrace');
      SnackBarMessage.showErrorMessage('An unexpected error occurred: $e');

      return false;
    } finally {
      isCreating.value = false;
    }
  }

  // Delete a test question
  Future<bool> deleteTestQuestion(String testId) async {
    try {
      DialogUtils.showLoadingDialog(message: 'Deleting lesson test...');

      await Future.delayed(const Duration(seconds: 2));
      isDeleting.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final ApiResponse<bool> response =
          await CourseTestServices.deleteTestQuestion(
            courseId: courseIdController.text.trim(),
            testId: testId,
          );
      DialogUtils.hideDialog(); // Hide loading dialog

      if (response.success) {
        testQuestions.removeWhere((question) => question.id == testId);
        log('Test question deleted successfully: $testId');

        SnackBarMessage.showSuccessMessage(
          'Test question deleted successfully',
        );
        return true;
      } else {
        log('Failed to delete test question: ${response.message}');
        SnackBarMessage.showErrorMessage(
          'Failed to delete test question ${response.message}',
        );
        return false;
      }
    } catch (e) {
      log('Error deleting test question: $e');
      SnackBarMessage.showErrorMessage('An unexpected error occurred');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // Update lesson test
  Future<bool> updateTestQuestion(String? testId) async {
    isUpdating.value = true;
    await Future.delayed(Duration(seconds: 2));
    isUpdating.value = false;

    return false;
  }

  void populateFormWithQuestion(CourseTestModel question) {
    titleController.text = question.title;
    courseIdController.text = question.lessonId;
    selectedCorrectAnswer.value = question.correctAnswer;

    _disposeQuestionControllers();
    questionControllers.clear();

    for (int i = 0; i < question.questions.length; i++) {
      questionControllers.add(
        TextEditingController(text: question.questions[i].question),
      );
    }
  }

  void clearForm() {
    titleController.clear();
    courseIdController.clear();
    selectedCorrectAnswers.clear();
    questionControllers.clear();

    questionControllers.add(TextEditingController());
    selectedCorrectAnswers.add(0);
  }

  bool _validateForm() {
    // Clear previous errors
    errorMessage.value = '';

    // Check overall test title
    if (titleController.text.trim().isEmpty) {
      errorMessage.value = 'Test title is required';
      return false;
    }

    // Check lesson ID
    if (courseIdController.text.trim().isEmpty) {
      errorMessage.value = 'Lesson ID is required';
      return false;
    }

    // Check if we have questions
    if (questionControllers.isEmpty) {
      errorMessage.value = 'At least one question is required';
      return false;
    }

    // Check if all questions have titles and text
    for (int i = 0; i < questionControllers.length; i++) {
      if (questionControllers[i].text.trim().isEmpty) {
        errorMessage.value = 'Question ${i + 1} text is required';
        return false;
      }
    }

    // Check correct answer selection
    if (selectedCorrectAnswer.value < 0) {
      errorMessage.value = 'Please select a correct answer';
      return false;
    }

    return true;
  }

  void selectTestQuestion(CourseTestModel? question) {
    selectedTestQuestion.value = question;
  }

  void clearSelectedTestQuestion() {
    selectedTestQuestion.value = null;
  }
}
