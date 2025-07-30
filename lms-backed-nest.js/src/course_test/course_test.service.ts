import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Course, CourseDocument } from 'src/schema/course.schema';
import { CreateTestDto } from './create-test.dto';
import { CourseTest, CourseTestDocument } from 'src/schema/course.test.schema';

@Injectable()
export class CourseTestService {
  constructor(
    @InjectModel(CourseTest.name)
    private readonly testModel: Model<CourseTestDocument>,
    @InjectModel(Course.name)
    private readonly courseModel: Model<CourseDocument>,
  ) {}

  /**
   * Create a new course test and associate it with a course
   */
  async create(createTestDto: CreateTestDto): Promise<CourseTest> {
    // Validate DTO
    if (!createTestDto.course) {
      throw new BadRequestException('Course ID is required');
    }

    // Verify the course exists
    console.log(createTestDto.course);
    
    const course = await this.courseModel.findById(createTestDto.course);
    if (!course) {
      throw new NotFoundException('Course not found');
    }

    // Create the test
    const test = new this.testModel({
      ...createTestDto,
      course: new Types.ObjectId(createTestDto.course)
    });
    const savedTest = await test.save();

    // Update course with test reference
    await this.courseModel.findByIdAndUpdate(
      createTestDto.course,
      { $addToSet: { tests: savedTest._id } },
      { new: true },
    );

    return savedTest;
  }

  /**
   * Find all tests for a given course
   */
  async findAllByCourse(courseId: string): Promise<CourseTest[]> {
    if (!Types.ObjectId.isValid(courseId)) {
      throw new BadRequestException('Invalid course ID');
    }

    const course = await this.courseModel
      .findById(courseId)
      .populate<{ tests: CourseTest[] }>('tests')
      .lean();
    if (!course) {
      throw new NotFoundException('Course not found');
    }

    return course.tests || [];
  }

  /**
   * Find all tests in the database
   */
  async findAll(): Promise<CourseTest[]> {
    return this.testModel.find().populate('course').lean();
  }

  /**
   * Find a single test by ID
   */
  async findOne(id: string): Promise<CourseTest> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid test ID');
    }

    const test = await this.testModel.findById(id).populate('course').lean();
    if (!test) {
      throw new NotFoundException('Test not found');
    }
    return test;
  }

  /**
   * Delete a test by ID
   */
  async remove(id: string): Promise<{ deleted: boolean; message: string }> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid test ID');
    }

    // Find and delete the test
    const test = await this.testModel.findByIdAndDelete(id);
    if (!test) {
      throw new NotFoundException('Test not found');
    }

    // Remove test reference from course
    await this.courseModel.findByIdAndUpdate(
      test.course,
      { $pull: { tests: test._id } },
    );

    return { deleted: true, message: 'Test deleted successfully' };
  }
}