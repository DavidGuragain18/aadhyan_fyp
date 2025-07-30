import { Controller, Get, Post, Put, Delete, Param, Body, Query } from '@nestjs/common';
import { CourseReviewService } from './course-review.service';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery } from '@nestjs/swagger';
import { CourseReview } from 'src/schema/course_reviews';
import { CreateReviewDto } from './create_review.dto';
import { UpdateReviewDto } from './update_review.dto';

@ApiTags('course-reviews')
@Controller('course-reviews')
export class CourseReviewController {
  constructor(private readonly courseReviewService: CourseReviewService) { }

  @Post()
  @ApiOperation({ summary: 'Create a new course review' })
  @ApiResponse({ status: 201, description: 'Review created successfully', type: CourseReview })
  @ApiResponse({ status: 400, description: 'Invalid input or user already reviewed course' })
  @ApiResponse({ status: 404, description: 'Course not found' })
  create(@Body() createReviewDto: CreateReviewDto) {
    return this.courseReviewService.create(createReviewDto);
  }

  @Get('course/:courseId')
  @ApiOperation({ summary: 'Get all reviews for a course' })
  @ApiParam({ name: 'courseId', description: 'ID of the course', example: '687dfbe86be859bf15944437' })
  @ApiResponse({ status: 200, description: 'List of reviews', type: [CourseReview] })
  @ApiResponse({ status: 400, description: 'Invalid course ID' })
  @ApiResponse({ status: 404, description: 'Course not found' })
  findAllByCourse(@Param('courseId') courseId: string) {
    return this.courseReviewService.findAllByCourse(courseId, );
  }

  @Get()
  @ApiOperation({ summary: 'Get all reviews' })
  @ApiQuery({ name: 'approvedOnly', required: false, type: Boolean, description: 'Filter by approved reviews only', example: true })
  @ApiResponse({ status: 200, description: 'List of all reviews', type: [CourseReview] })
  findAll(@Query('approvedOnly') approvedOnly: string = 'true') {
    return this.courseReviewService.findAll(approvedOnly === 'true');
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a review by ID' })
  @ApiParam({ name: 'id', description: 'ID of the review', example: '687dfbe86be859bf15944441' })
  @ApiResponse({ status: 200, description: 'Review details', type: CourseReview })
  @ApiResponse({ status: 400, description: 'Invalid review ID' })
  @ApiResponse({ status: 404, description: 'Review not found' })
  findOne(@Param('id') id: string) {
    return this.courseReviewService.findOne(id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a review by ID' })
  @ApiParam({ name: 'id', description: 'ID of the review', example: '687dfbe86be859bf15944441' })
  @ApiResponse({ status: 200, description: 'Updated review', type: CourseReview })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 404, description: 'Review or course not found' })
  update(@Param('id') id: string, @Body() updateReviewDto: UpdateReviewDto) {
    return this.courseReviewService.update(id, updateReviewDto);
  }

  

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a review by ID' })
  @ApiParam({ name: 'id', description: 'ID of the review', example: '687dfbe86be859bf15944441' })
  @ApiResponse({ status: 200, description: 'Review deleted', type: Object })
  @ApiResponse({ status: 400, description: 'Invalid review ID' })
  @ApiResponse({ status: 404, description: 'Review not found' })
  remove(@Param('id') id: string) {
    return this.courseReviewService.remove(id);
  }

  @Get('count/:courseId')
  @ApiOperation({ summary: 'Count reviews for a course' })
  @ApiParam({ name: 'courseId', description: 'ID of the course', example: '687dfbe86be859bf15944437' })
  @ApiQuery({ name: 'approvedOnly', required: false, type: Boolean, description: 'Count only approved reviews', example: true })
  @ApiResponse({ status: 200, description: 'Number of reviews', type: Number })
  @ApiResponse({ status: 400, description: 'Invalid course ID' })
  @ApiResponse({ status: 404, description: 'Course not found' })
  countByCourse(@Param('courseId') courseId: string, @Query('approvedOnly') approvedOnly: string = 'true') {
    return this.courseReviewService.countByCourse(courseId, approvedOnly === 'true');
  }
}