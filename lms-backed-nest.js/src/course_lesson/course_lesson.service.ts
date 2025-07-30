import { BadRequestException, HttpCode, Inject, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Course, CourseDocument } from 'src/schema/course.schema';
import { CourseLesson, CourseLessonDocument } from 'src/schema/course_lesson.schema';
import { CreateCourseLessonDto } from './create-course-lesson.dto';
import { UpdateCourseLessonDto } from './update-course-lesson.dto';
import { REQUEST } from '@nestjs/core';

@Injectable()
export class CourseLessonService {
  constructor(
    @InjectModel(CourseLesson.name)
    private readonly lessonModel: Model<CourseLessonDocument>,
    @InjectModel(Course.name)
    private readonly courseModel: Model<CourseDocument>,
    @Inject(REQUEST) private request: Request
  ) { }

  async create(
    createCourseLessonDto: CreateCourseLessonDto,
    courseId: string,
    pdfUrl: Express.Multer.File,
  ): Promise<CourseLesson> {
    let pdf: string | null = null;

    // Construct PDF URL (assuming pdfUrl.path is the file path from Multer)
    pdf = `/course-covers/${pdfUrl.filename || pdfUrl.path}`; // Use filename if available
    console.log('PDF URL:', pdf);

    // Validate and convert courseId to ObjectId
    let formattedCourseId: Types.ObjectId;
    try {
      formattedCourseId = new Types.ObjectId(courseId.trim());
    } catch (error) {
      throw new NotFoundException('Invalid course ID format');
    }

    // 1. Verify the course exists
    const course = await this.courseModel.findById(formattedCourseId);
    if (!course) {
      throw new NotFoundException(`Course not found with ID ${courseId}`);
    }

    // 2. Create lesson data
    const lessonData = {
      ...createCourseLessonDto,
      course: formattedCourseId, // Store the ObjectId reference
      pdfUrl: pdf,
    };
    console.log('Lesson data:', lessonData);

    // 3. Create and save lesson
    let savedLesson: CourseLessonDocument;
    try {
      const lesson = new this.lessonModel(lessonData);
      savedLesson = await lesson.save();
      console.log('Saved lesson:', savedLesson);
    } catch (error) {
      console.error('Save error:', error.message);
      throw new Error(`Failed to save lesson: ${error.message}`);
    }

    // 4. Update the course's lessons array
    await this.courseModel.findByIdAndUpdate(
      formattedCourseId,
      { $push: { lessons: savedLesson._id } },
      { new: true, runValidators: true },
    ).exec();

    return savedLesson;
  }

async findAllByCourse(courseId: string): Promise<CourseLesson[]> {
  // Validate courseId
  if (!Types.ObjectId.isValid(courseId)) {
    throw new BadRequestException('Invalid course ID');
  }

  console.log('Received courseId:', courseId);

  // No need to manually create ObjectId since findById handles string-to-ObjectId conversion
  const course = await this.courseModel
    .findById(courseId)
    .populate<{ lessons: CourseLesson[] }>({
      path: 'lessons',
      populate: {
        path: 'tests',
        model: 'LessonTest',
      },
    })
    .lean();

  if (!course) {
    throw new NotFoundException('Course not found');
  }

  if (!course.lessons || course.lessons.length === 0) {
    console.log('No lessons found for this course');
    return [];
  }

  return course.lessons;
}

  async findOne(id: string): Promise<CourseLesson> {
    const lesson = await this.lessonModel.findById(id);
    if (!lesson) {
      throw new NotFoundException('Lesson not found');
    }
    return lesson;
  }


  async update(
    lessonId: string,
    updateCourseLessonDto: UpdateCourseLessonDto,
    pdfUrl?: Express.Multer.File
  ): Promise<CourseLesson> {
    // Determine PDF path if a new file is uploaded
    let updatedFields: any = { ...updateCourseLessonDto };

    if (pdfUrl) {
      updatedFields.pdfUrl = "/course-covers/" + pdfUrl.filename;
    }

    // Hardcoded ID for testing
    const hardcodedLessonId = new Types.ObjectId(lessonId);

    const lesson = await this.lessonModel.findByIdAndUpdate(hardcodedLessonId, updatedFields, { new: true });

    if (!lesson) {
      throw new NotFoundException('Lesson not found');
    }

    return lesson;
  }


  async remove(id: string): Promise<{ deleted: boolean; message?: string }> {
    // Find the lesson to get the course reference
    const lesson = await this.lessonModel.findByIdAndDelete(id);
    if (!lesson) {
      throw new NotFoundException('Lesson not found');
    }

    // Remove the lesson reference from the course
    await this.courseModel.findByIdAndUpdate(
      lesson.course,
      { $pull: { lessons: lesson._id } },
    );

    return { deleted: true };
  }
}