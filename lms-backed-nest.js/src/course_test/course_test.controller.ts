import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { CourseTestService } from './course_test.service';
import { CreateTestDto } from './create-test.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiBody, ApiQuery } from '@nestjs/swagger';
import { CourseTest } from 'src/schema/course.test.schema';

@ApiTags('course-tests')  // Changed from 'lesson-tests'
@Controller('/course-tests')  // Changed from '/tests'
export class CourseTestController {
  constructor(private readonly testService: CourseTestService) {}  // Changed to CourseTestService

  @Post("")  // Changed from :lessonId
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new test for a course' })  // Updated summary

  @ApiBody({ type: CreateTestDto, description: 'Test creation data' })
  @ApiResponse({ 
    status: 201, 
    description: 'Test created successfully', 
    type: CourseTest  // Changed from LessonTest
  })
  @ApiResponse({ status: 400, description: 'Bad Request - Invalid input data' })
  async create(
    
    @Body() createTestDto: CreateTestDto,
  ): Promise<CourseTest> {  // Changed return type
    return this.testService.create({ 
      ...createTestDto, 
    });
  }

  @Get(":courseId")  // Changed from :lessonId
  @ApiOperation({ summary: 'Get all tests for a specific course' })  // Updated summary
  @ApiParam({ 
    name: 'courseId',  // Changed from lessonId
    description: 'ID of the course', 
    example: '687dfbe86be859bf15944438' 
  })
  @ApiResponse({ 
    status: 200, 
    description: 'List of tests retrieved successfully', 
    type: [CourseTest]  // Changed from [LessonTest]
  })
  @ApiResponse({ status: 404, description: 'Course not found' })  // Changed from Lesson
  async findAllByCourse(  // Renamed from findAllByLesson
    @Param('courseId') courseId: string,  // Changed from lessonId
  ): Promise<CourseTest[]> {  // Changed return type
    return this.testService.findAllByCourse(courseId);  // Changed method call
  }

  @Get(':testId')
  @ApiOperation({ summary: 'Get a specific test by ID' })
  @ApiParam({ 
    name: 'testId', 
    description: 'ID of the test', 
    example: '550e8400-e29b-41d4-a716-446655440000' 
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Test retrieved successfully', 
    type: CourseTest  // Changed from LessonTest
  })
  @ApiResponse({ status: 404, description: 'Test not found' })
  async findOne(
    @Param('testId') testId: string,
  ): Promise<CourseTest> {  // Changed return type
    return this.testService.findOne(testId);
  }

  @Delete(':testId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a specific test by ID' })
  @ApiParam({ 
    name: 'testId', 
    description: 'ID of the test', 
    example: '550e8400-e29b-41d4-a716-446655440000' 
  })
  @ApiResponse({ status: 204, description: 'Test deleted successfully' })
  @ApiResponse({ status: 404, description: 'Test not found' })
  async remove(
    @Param('testId') testId: string,
  ): Promise<{ deleted: boolean; message?: string }> {
    return this.testService.remove(testId);
  }
}