import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/course/test_question_controller.dart';
import '../../../model/course/lesson_test_question_model.dart';

class AddEditTestQuestionScreen extends StatefulWidget {
  final String? lessonId;
  final String? lessonTitle;
  final LessonTestQuestionModel? testQuestion;

  const AddEditTestQuestionScreen({
    Key? key,
    this.lessonId,
    this.lessonTitle,
    this.testQuestion,
  }) : super(key: key);

  @override
  _AddEditTestQuestionScreenState createState() =>
      _AddEditTestQuestionScreenState();
}

class _AddEditTestQuestionScreenState extends State<AddEditTestQuestionScreen> {
  final LessonTestQuestionController controller =
      Get.find<LessonTestQuestionController>();
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
      controller.selectedCorrectAnswers.add(0); // Default: Option A

      if (widget.lessonId != null) {
        controller.lessonIdController.text = widget.lessonId!;
      }
      if (widget.lessonTitle != null) {
        controller.titleController.text = widget.lessonTitle!;
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
                      ? 'Editing test question for lesson ${widget.lessonId}'
                      : 'Adding test question to lesson ${widget.lessonId}',
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
          _buildSectionTitle('Test Question Details'),
          const SizedBox(height: 20),
          _buildQuestionsSection(),
          const SizedBox(height: 20),
          if (controller.errorMessage.value.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],
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
        const Text(
          'Question *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
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
          const Text(
            'Question',
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
                  ? 'Exactly 4 options required'
                  : 'Add Option',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildOptionsList(questionIndex),
      ],
    );
  }

  // Widget _buildOptionsSection(int questionIndex) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           const Text(
  //             'Answer Options',
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w600,
  //               color: Color(0xFF1E293B),
  //             ),
  //           ),
  //           Container(
  //             decoration: BoxDecoration(
  //               color: const Color(0xFF667EEA).withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: IconButton(
  //               onPressed: _optionControllersList[questionIndex].length >= 4
  //                   ? null
  //                   : () {
  //                       setState(() {
  //                         _optionControllersList[questionIndex].add(
  //                           TextEditingController(),
  //                         );
  //                       });
  //                     },
  //               icon: Icon(
  //                 Icons.add_rounded,
  //                 color: _optionControllersList[questionIndex].length >= 4
  //                     ? Colors.grey
  //                     : const Color(0xFF667EEA),
  //               ),
  //               tooltip: _optionControllersList[questionIndex].length >= 4
  //                   ? 'Maximum 4 options allowed'
  //                   : 'Add Option',
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 16),
  //       _buildOptionsList(questionIndex),
  //     ],
  //   );
  // }

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
                  controller.selectedCorrectAnswers[questionIndex] ==
                      optionIndex
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE2E8F0),
              width: controller.selectedCorrectAnswer.value == optionIndex
                  ? 2
                  : 2,
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
                          controller.selectedCorrectAnswers[questionIndex] ==
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
                            controller.selectedCorrectAnswers[questionIndex] ==
                                optionIndex
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        controller.selectedCorrectAnswers[questionIndex] ==
                                optionIndex
                            ? 'Correct'
                            : 'Select',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color:
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
                          if (controller.selectedCorrectAnswer.value ==
                              optionIndex) {
                            controller.selectedCorrectAnswer.value = 0;
                          } else if (controller.selectedCorrectAnswer.value >
                              optionIndex) {
                            controller.selectedCorrectAnswer.value--;
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
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 14),
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
        child: ElevatedButton.icon(
          onPressed: controller.isCreating.value || controller.isUpdating.value
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
                ? (isEditMode ? 'Updating Question...' : 'Creating Question...')
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
    );
  }

  Future<void> _submitTestQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (controller.questionControllers.isEmpty) {
      controller.errorMessage.value = 'At least one question is required';
      return;
    }

    bool hasQuestionsWithoutOptions = false;
    for (int i = 0; i < _optionControllersList.length; i++) {
      if (_optionControllersList[i].isEmpty) {
        hasQuestionsWithoutOptions = true;
        break;
      }
    }

    if (hasQuestionsWithoutOptions) {
      controller.errorMessage.value =
          'All questions must have at least one option';
      return;
    }

    if (controller.selectedCorrectAnswers.isEmpty ||
        controller.selectedCorrectAnswers.any((i) => i < 0)) {
      controller.errorMessage.value =
          'Please select a correct answer for each question';
      return;
    }

    if (controller.selectedCorrectAnswers[0] >=
        _optionControllersList[0].length) {
      controller.errorMessage.value = 'Selected correct answer is invalid';
      return;
    }

    final optionsList = _optionControllersList
        .map(
          (controllers) =>
              controllers.map((controller) => controller.text.trim()).toList(),
        )
        .toList();

    bool success;
    if (isEditMode) {
      success = await controller.updateTestQuestion(widget.testQuestion!.id!);
    } else {
      success = await controller.createTestQuestion(optionsList: optionsList);
    }

    if (success) {
      Get.back();
    }
  }
}
