import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fyp/core/utility/clear_focus.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../controller/course/course_lesson_controller.dart';
import '../../../model/course/course_model.dart';
import '../../../model/course/course_lesson_model.dart';

class AddEditLessonScreen extends StatefulWidget {
  final CourseModel course;
  final CourseLessonModel? lesson; // Null for add, non-null for edit

  const AddEditLessonScreen({Key? key, required this.course, this.lesson})
    : super(key: key);

  @override
  State<AddEditLessonScreen> createState() => _AddEditLessonScreenState();
}

class _AddEditLessonScreenState extends State<AddEditLessonScreen> {
  final CourseLessonController _controller = Get.find<CourseLessonController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers are already available in the controller
  final TextEditingController _keywordInputController = TextEditingController();

  // PDF file handling
  File? _selectedPdfFile;
  String? _selectedPdfName;
  bool _isUploading = false;

  // Keywords management
  late List<String> _keywords;

  // Check if this is edit mode
  bool get isEditMode => widget.lesson != null;

  @override
  void initState() {
    super.initState();
    // Set the current course ID in the controller
    _controller.setCurrentCourseId(widget.course.id);

    if (isEditMode) {
      _initializeWithLessonData();
    } else {
      // Clear any existing data for add mode
      _controller.clearControllers();
      _controller.clearMessages();
      _keywords = [];
    }
  }

  void _initializeWithLessonData() {
    // Populate controllers with existing lesson data
    _controller.titleController.text = widget.lesson!.title;
    _controller.descriptionController.text = widget.lesson!.description;
    _controller.readingDurationController.text = widget.lesson!.readingDuration
        .toString();

    // Initialize keywords
    _keywords = List<String>.from(widget.lesson!.keywords);
    _controller.keywordsController.text = _keywords.join(', ');

    // Set existing PDF info if available
    if (widget.lesson!.hasPdf) {
      _selectedPdfName =
          widget.lesson!.pdfUrl?.split('/').last ?? 'Existing PDF';
    }

    _controller.clearMessages();
  }

  @override
  void dispose() {
    _keywordInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        isEditMode ? 'Edit Lesson' : 'Add New Lesson',
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
            _buildCourseInfo(),
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

  Widget _buildCourseInfo() {
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
              isEditMode ? Icons.edit : Icons.book,
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
                  widget.course.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditMode
                      ? 'Editing: ${widget.lesson!.title}'
                      : 'Adding lesson to this course',
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
      padding: const EdgeInsets.all(24),
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
          _buildSectionTitle('Lesson Details'),
          const SizedBox(height: 20),
          _buildTitleField(),
          const SizedBox(height: 20),
          _buildDescriptionField(),
          const SizedBox(height: 20),
          _buildReadingDurationField(),
          const SizedBox(height: 24),
          _buildKeywordsSection(),
          const SizedBox(height: 24),
          _buildPdfUploadSection(),
          if (_controller.errorMessage.value.isNotEmpty) ...[
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

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lesson Title *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller.titleController,
          decoration: InputDecoration(
            hintText: 'Enter lesson title',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller.descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter lesson description',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildReadingDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reading Duration (minutes) *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller.readingDurationController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter reading duration in minutes',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: const Icon(Icons.access_time, color: Color(0xFF9CA3AF)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Reading duration is required';
            }
            int? duration = int.tryParse(value.trim());
            if (duration == null || duration <= 0) {
              return 'Duration must be greater than 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildKeywordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keywords *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add keywords to help users find this lesson',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 12),
        _buildKeywordInput(),
        const SizedBox(height: 12),
        _buildKeywordsList(),
        if (_keywords.isEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'At least one keyword is required',
            style: TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
          ),
        ],
      ],
    );
  }

  Widget _buildKeywordInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _keywordInputController,
            decoration: InputDecoration(
              hintText: 'Enter a keyword',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF6366F1),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onFieldSubmitted: _addKeyword,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => _addKeyword(_keywordInputController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
          ),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildKeywordsList() {
    if (_keywords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Center(
          child: Text(
            'No keywords added yet',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _keywords.map((keyword) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                keyword,
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _removeKeyword(keyword),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPdfUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PDF Document *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isEditMode
              ? 'Upload a new PDF document to replace the existing one (optional)'
              : 'Upload a PDF document for this lesson',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 12),
        _buildPdfUploadWidget(),
      ],
    );
  }

  Widget _buildPdfUploadWidget() {
    bool hasExistingPdf =
        isEditMode && widget.lesson!.hasPdf && _selectedPdfFile == null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_selectedPdfFile != null || hasExistingPdf)
              ? const Color(0xFF10B981)
              : const Color(0xFFE5E7EB),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          if (_selectedPdfFile == null && !hasExistingPdf) ...[
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            const Text(
              'Click to upload PDF',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Maximum file size: 10MB',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ] else if (hasExistingPdf) ...[
            Icon(
              Icons.picture_as_pdf,
              size: 48,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedPdfName ?? 'Current PDF',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Current PDF file',
              style: TextStyle(fontSize: 12, color: Color(0xFF10B981)),
              textAlign: TextAlign.center,
            ),
          ] else if (_selectedPdfFile != null) ...[
            Icon(
              Icons.picture_as_pdf,
              size: 48,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedPdfName ?? 'Unknown file',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              isEditMode ? 'New PDF selected' : 'PDF selected',
              style: const TextStyle(fontSize: 12, color: Color(0xFF10B981)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _removePdf,
              icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
              label: const Text(
                'Remove PDF',
                style: TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickPdf,
            icon: _isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.attach_file),
            label: Text(
              _isUploading
                  ? 'Selecting...'
                  : _selectedPdfFile != null
                  ? 'Change File'
                  : hasExistingPdf
                  ? 'Replace File'
                  : 'Choose File',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
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
              _controller.errorMessage.value,
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
      child: ElevatedButton.icon(
        onPressed: _controller.isCreating.value ? null : _submitLesson,
        icon: _controller.isCreating.value
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
          _controller.isCreating.value
              ? (isEditMode ? 'Updating Lesson...' : 'Creating Lesson...')
              : (isEditMode ? 'Update Lesson' : 'Create Lesson'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  void _addKeyword(String keyword) {
    String trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isNotEmpty && !_keywords.contains(trimmedKeyword)) {
      setState(() {
        _keywords.add(trimmedKeyword);
      });
      _keywordInputController.clear();
    }
  }

  void _removeKeyword(String keyword) {
    setState(() {
      _keywords.remove(keyword);
    });
  }

  Future<void> _pickPdf() async {
    try {
      setState(() {
        _isUploading = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        // Check file size (10MB limit)
        int fileSizeInBytes = await file.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 10) {
          Get.snackbar(
            'Error',
            'File size exceeds 10MB limit',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        setState(() {
          _selectedPdfFile = file;
          _selectedPdfName = result.files.single.name;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _removePdf() {
    setState(() {
      _selectedPdfFile = null;
      _selectedPdfName = null;
    });
  }

  Future<void> _submitLesson() async {
    // Clear previous messages
    _controller.clearMessages();

    // _clearAllFocus();
    ClearFocus.clearAllFocus(context);

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate keywords
    if (_keywords.isEmpty) {
      _controller.errorMessage.value = 'At least one keyword is required';
      return;
    }

    // Validate PDF for add mode only
    if (!isEditMode && _selectedPdfFile == null) {
      _controller.errorMessage.value = 'PDF document is required';
      return;
    }

    // Set keywords in the controller
    _controller.keywordsController.text = _keywords.join(', ');

    try {
      bool success;

      if (isEditMode) {
        // Update existing lesson
        success = await _controller.updateCourseLesson(
          widget.lesson!.id,
          courseId: widget.course.id,
          pdfPath: _selectedPdfFile?.path,
        );
        if (success) {
          Navigator.pop(context);
        }
      } else {
        // Create new lesson
        success = await _controller.createCourseLesson(
          courseId: widget.course.id,
          pdfPath: _selectedPdfFile?.path,
        );
        // if (success) {
        //   Navigator.pop(context);
        // }
      }

      if (success) {
        // Navigate back on success
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        isEditMode
            ? 'Failed to update lesson: ${e.toString()}'
            : 'Failed to create lesson: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
