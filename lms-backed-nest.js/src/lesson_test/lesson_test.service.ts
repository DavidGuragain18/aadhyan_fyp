import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { CourseLesson, CourseLessonDocument } from 'src/schema/course_lesson.schema';
import { CreateTestDto } from './create-test.dto';
import { LessonTest, LessonTestDocument } from 'src/schema/lesson.test.schema';

@Injectable()
export class LessonTestService {
  constructor(
    @InjectModel(LessonTest.name)
    private readonly testModel: Model<LessonTestDocument>,
    @InjectModel(CourseLesson.name)
    private readonly lessonModel: Model<CourseLessonDocument>,
  ) {}

  /**
   * Create a new lesson test and associate it with a lesson
   */
  async create(createTestDto: CreateTestDto): Promise<LessonTest> {
    // Validate DTO

    // Verify the lesson exists
    const lesson = await this.lessonModel.findById(createTestDto.lesson);
    if (!lesson) {
      throw new NotFoundException('Lesson not found');
    }

    // Create the test
    const test = new this.testModel(createTestDto);
    const savedTest = await test.save();


console.log(savedTest);

    // Update lesson with test reference
    await this.lessonModel.findByIdAndUpdate(
      createTestDto.lesson,
      { $addToSet: { tests: savedTest._id } }, // Use $addToSet to prevent duplicates
      { new: true },
    );

    return savedTest.populate('lesson');
  }

  /**
   * Find all tests for a given lesson
   */
 async findAllByLesson(lessonId: string): Promise<LessonTest[]> {
  // Validate lessonId
  if (!Types.ObjectId.isValid(lessonId)) {
    throw new BadRequestException('Invalid lesson ID');
  }

  const lesson = await this.lessonModel
    .findById(lessonId)
    .populate<{ tests: LessonTest[] }>('tests') // Explicitly type the populated field
    .lean();
  if (!lesson) {
    throw new NotFoundException('Lesson not found');
  }

  return lesson.tests || [];
}

  /**
   * Find all tests in the database
   */
  async findAll(): Promise<LessonTest[]> {
    return this.testModel.find().populate('lesson').lean();
  }

  /**
   * Find a single test by ID
   */
  async findOne(id: string): Promise<LessonTest> {
    // Validate test ID
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid test ID');
    }

    const test = await this.testModel.findById(id).populate('lesson').lean();
    if (!test) {
      throw new NotFoundException('Test not found');
    }
    return test;
  }



  /**
   * Delete a test by ID
   */
  async remove(id: string): Promise<{ deleted: boolean; message: string }> {
    // Validate test ID
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid test ID');
    }

    // Find and delete the test
    const test = await this.testModel.findByIdAndDelete(id);
    if (!test) {
      throw new NotFoundException('Test not found');
    }

    // Remove test reference from lesson
    await this.lessonModel.findByIdAndUpdate(
      test.lesson,
      { $pull: { tests: test._id } },
    );

    return { deleted: true, message: 'Test deleted successfully' };
  }



}