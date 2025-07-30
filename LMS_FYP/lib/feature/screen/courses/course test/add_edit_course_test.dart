import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/course/course_test_controller.dart';
import '../../../model/course/course_test_model.dart';

class AddEditCourseTestScreen extends StatefulWidget {
  final String? courseId;
  final CourseTestModel? testQuestion;

  const AddEditCourseTestScreen({Key? key, this.courseId, this.testQuestion})
    : super(key: key);

  @override
  _AddEditCourseTestScreenState createState() =>
      _AddEditCourseTestScreenState();
}

class _AddEditCourseTestScreenState extends State<AddEditCourseTestScreen> {
  final CourseTestController controller = Get.find<CourseTestController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _optionInputController = TextEditingController();
  late List<List<TextEditingController>> _optionControllersList;

  bool get isEditMode => widget.testQuestion != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _initializeWithQuestionData();
    } else {
      controller.clearForm();
      controller.questionControllers.clear();

      controller.questionControllers.add(TextEditingController());
      _optionControllersList = [<TextEditingController>[]];
      controller.selectedCorrectAnswers.clear();
      controller.selectedCorrectAnswers.add(0);

      if (widget.courseId != null) {
        controller.courseIdController.text = widget.courseId!;
      }
    }
  }

  void _initializeWithQuestionData() {
    _optionControllersList = widget.testQuestion!.questions
        .map(
          (q) => q.options
              .map((option) => TextEditingController(text: option))
              .toList(),
        )
        .toList();

    controller.questionControllers.clear();
    controller.selectedCorrectAnswers.clear();

    for (var question in widget.testQuestion!.questions) {
      controller.questionControllers.add(
        TextEditingController(text: question.question),
      );
    }

    controller.selectedCorrectAnswers.add(widget.testQuestion!.correctAnswer);
  }

  @override
  void dispose() {
    _optionInputController.dispose();
    for (var controllers in _optionControllersList) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        isEditMode ? 'Edit Test Question' : 'Add New Test Question',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTestInfo(),
            const SizedBox(height: 24),
            _buildTestTitleCard(),
            const SizedBox(height: 24),
            _buildFormCard(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTestInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditMode ? Icons.edit : Icons.quiz,
              color: const Color(0xFF6366F1),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? widget.testQuestion!.title : 'New Test Question',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditMode
                      ? 'Editing test question for lesson ${widget.courseId}'
                      : 'Adding test question to lesson ${widget.courseId}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestTitleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Test Title *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.titleController,
            decoration: InputDecoration(
              hintText: 'Enter overall test title...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF6366F1),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Test title is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Test Questions'),
          const SizedBox(height: 20),
          _buildQuestionsSection(),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              return Column(
                children: [const SizedBox(height: 16), _buildErrorMessage()],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Questions *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            if (controller.questionControllers.length < 10)
              IconButton(
                onPressed: () {
                  setState(() {
                    controller.addQuestion();
                    _optionControllersList.add(<TextEditingController>[]);
                  });
                },
                icon: const Icon(Icons.add_circle, color: Color(0xFF6366F1)),
                tooltip: 'Add Question',
              ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => Column(
            children: controller.questionControllers.asMap().entries.map((
              entry,
            ) {
              final index = entry.key;
              final questionController = entry.value;
              return _buildQuestionField(index, questionController);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionField(
    int index,
    TextEditingController questionController,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              if (controller.questionControllers.length > 1)
                IconButton(
                  onPressed: () {
                    setState(() {
                      controller.removeQuestion(index);
                      if (index < _optionControllersList.length) {
                        for (var controller in _optionControllersList[index]) {
                          controller.dispose();
                        }
                        _optionControllersList.removeAt(index);
                      }
                    });
                  },
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  tooltip: 'Remove Question',
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Question Text Field
          const Text(
            'Question Text *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: questionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter your question here...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Question text is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildOptionsSection(index),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(int questionIndex) {
    // Ensure we have options list for this question
    if (questionIndex >= _optionControllersList.length) {
      _optionControllersList.add(<TextEditingController>[]);
    }

    final optionCount = _optionControllersList[questionIndex].length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Answer Options',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            IconButton(
              onPressed: optionCount >= 4
                  ? null
                  : () {
                      setState(() {
                        _optionControllersList[questionIndex].add(
                          TextEditingController(),
                        );
                      });
                    },
              icon: Icon(
                Icons.add_rounded,
                color: optionCount >= 4 ? Colors.grey : Color(0xFF667EEA),
              ),
              tooltip: optionCount >= 4
                  ? 'Maximum 4 options allowed'
                  : 'Add Option',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildOptionsList(questionIndex),
      ],
    );
  }

  Widget _buildOptionsList(int questionIndex) {
    final optionControllers = _optionControllersList[questionIndex];
    if (optionControllers.isEmpty) {
      return const Text(
        'No options added yet',
        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      );
    }
    return Column(
      children: optionControllers.asMap().entries.map((entry) {
        final optionIndex = entry.key;
        final optionController = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  questionIndex < controller.selectedCorrectAnswers.length &&
                      controller.selectedCorrectAnswers[questionIndex] ==
                          optionIndex
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE2E8F0),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          questionIndex <
                                  controller.selectedCorrectAnswers.length &&
                              controller
                                      .selectedCorrectAnswers[questionIndex] ==
                                  optionIndex
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                      borderRadius: BorderRadius.circular(12),
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
                      'Option ${String.fromCharCode(65 + optionIndex)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        // Ensure we have enough elements in selectedCorrectAnswers
                        while (controller.selectedCorrectAnswers.length <=
                            questionIndex) {
                          controller.selectedCorrectAnswers.add(0);
                        }
                        controller.selectedCorrectAnswers[questionIndex] =
                            optionIndex;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            questionIndex <
                                    controller.selectedCorrectAnswers.length &&
                                controller
                                        .selectedCorrectAnswers[questionIndex] ==
                                    optionIndex
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        questionIndex <
                                    controller.selectedCorrectAnswers.length &&
                                controller
                                        .selectedCorrectAnswers[questionIndex] ==
                                    optionIndex
                            ? 'Correct'
                            : 'Select',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color:
                              questionIndex <
                                      controller
                                          .selectedCorrectAnswers
                                          .length &&
                                  controller
                                          .selectedCorrectAnswers[questionIndex] ==
                                      optionIndex
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  if (optionControllers.length > 2) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _optionControllersList[questionIndex].removeAt(
                            optionIndex,
                          );

                          // Adjust selected correct answer if necessary
                          if (questionIndex <
                              controller.selectedCorrectAnswers.length) {
                            if (controller
                                    .selectedCorrectAnswers[questionIndex] ==
                                optionIndex) {
                              controller.selectedCorrectAnswers[questionIndex] =
                                  0;
                            } else if (controller
                                    .selectedCorrectAnswers[questionIndex] >
                                optionIndex) {
                              controller
                                  .selectedCorrectAnswers[questionIndex]--;
                            }
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.remove_rounded,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: optionController,
                decoration: const InputDecoration(
                  hintText: 'Enter option text...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Obx(
          () => ElevatedButton.icon(
            onPressed:
                controller.isCreating.value || controller.isUpdating.value
                ? null
                : _submitTestQuestion,
            icon: controller.isCreating.value || controller.isUpdating.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(isEditMode ? Icons.save : Icons.add),
            label: Text(
              controller.isCreating.value || controller.isUpdating.value
                  ? (isEditMode
                        ? 'Updating Question...'
                        : 'Creating Question...')
                  : (isEditMode ? 'Update Question' : 'Create Question'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitTestQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Clear any previous error messages
    controller.errorMessage.value = '';

    if (controller.questionControllers.isEmpty) {
      controller.errorMessage.value = 'At least one question is required';
      return;
    }

    // Check if all questions have options
    bool hasQuestionsWithoutOptions = false;
    for (int i = 0; i < _optionControllersList.length; i++) {
      if (_optionControllersList[i].isEmpty) {
        hasQuestionsWithoutOptions = true;
        controller.errorMessage.value =
            'Question ${i + 1} must have at least one option';
        break;
      }

      // Check if any options are empty
      for (int j = 0; j < _optionControllersList[i].length; j++) {
        if (_optionControllersList[i][j].text.trim().isEmpty) {
          controller.errorMessage.value =
              'All options must have text. Question ${i + 1}, Option ${j + 1} is empty';
          return;
        }
      }
    }

    if (hasQuestionsWithoutOptions) {
      return;
    }

    // Check if correct answers are selected for all questions
    for (int i = 0; i < controller.questionControllers.length; i++) {
      if (i >= controller.selectedCorrectAnswers.length ||
          controller.selectedCorrectAnswers[i] < 0 ||
          controller.selectedCorrectAnswers[i] >=
              _optionControllersList[i].length) {
        controller.errorMessage.value =
            'Please select a correct answer for question ${i + 1}';
        return;
      }
    }

    // Prepare options list
    final optionsList = _optionControllersList
        .map(
          (controllers) =>
              controllers.map((controller) => controller.text.trim()).toList(),
        )
        .toList();

    bool success;
    if (isEditMode) {
      success = await controller.updateTestQuestion(widget.testQuestion!.id);
    } else {
      success = await controller.createTestQuestion(optionsList: optionsList);
    }

    if (success) {
      Get.back();
    }
  }
}
