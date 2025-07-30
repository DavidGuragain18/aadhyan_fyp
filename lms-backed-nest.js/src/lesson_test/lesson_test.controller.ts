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
import { LessonTestService } from './lesson_test.service';
import { CreateTestDto } from './create-test.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiBody, ApiQuery } from '@nestjs/swagger';
import { LessonTest } from 'src/schema/lesson.test.schema';

@ApiTags('lesson-tests') 
@Controller('/tests')
export class LessonTestController {
  constructor(private readonly testService: LessonTestService) {}

  @Post(":lessonId")
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new test for a lesson' })
  @ApiParam({ name: 'lessonId', description: 'ID of the lesson', example: '687dfbe86be859bf15944438' })
  @ApiBody({ type: CreateTestDto, description: 'Test creation data' })
  @ApiResponse({ status: 201, description: 'Test created successfully', type: LessonTest })
  @ApiResponse({ status: 400, description: 'Bad Request - Invalid input data' })
  async create(
    @Param('lessonId') lessonId: string,
    @Body() createTestDto: CreateTestDto,
  ): Promise<LessonTest> {
    return this.testService.create({ ...createTestDto, lesson: lessonId });
  }

  @Get(":lessonId")
  @ApiOperation({ summary: 'Get all tests for a specific lesson' })
  @ApiParam({ name: 'lessonId', description: 'ID of the lesson', example: '687dfbe86be859bf15944438' })
  @ApiResponse({ status: 200, description: 'List of tests retrieved successfully', type: [LessonTest] })
  @ApiResponse({ status: 404, description: 'Lesson not found' })
  async findAllByLesson(
    @Param('lessonId') lessonId: string,
  ): Promise<LessonTest[]> {
    return this.testService.findAllByLesson(lessonId);
  }

  @Get(':testId')
  @ApiOperation({ summary: 'Get a specific test by ID' })
  @ApiParam({ name: 'testId', description: 'ID of the test ', example: '550e8400-e29b-41d4-a716-446655440000' })
  @ApiResponse({ status: 200, description: 'Test retrieved successfully', type: LessonTest })
  @ApiResponse({ status: 404, description: 'Test not found' })
  async findOne(
    @Param('testId') testId: string,
  ): Promise<LessonTest> {
    return this.testService.findOne(testId);
  }


  @Delete(':testId')
  @HttpCode(HttpStatus.NO_CONTENT) // Changed to 204 for DELETE success with no content
  @ApiOperation({ summary: 'Delete a specific test by ID' })
  @ApiParam({ name: 'testId', description: 'ID of the test', example: '550e8400-e29b-41d4-a716-446655440000' })
  @ApiResponse({ status: 204, description: 'Test deleted successfully' })
  @ApiResponse({ status: 404, description: 'Test not found' })
  async remove(
    @Param('testId') testId: string,
  ): Promise<{ deleted: boolean; message?: string }> {
    return this.testService.remove(testId);
  }


}