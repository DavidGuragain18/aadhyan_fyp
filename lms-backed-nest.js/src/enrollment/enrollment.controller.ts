import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards } from '@nestjs/common';
import { EnrollmentService } from './enrollment.service';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { CourseEnrollment } from 'src/schema/course_enrollment.schema';

import { User } from 'src/schema/user.schema';
import { CreateEnrollmentDto } from './create_enrollment.dto';
import { UpdateEnrollmentDto } from './update_enrollment_dto';

@ApiTags('enrollments')
@Controller('enrollments')
export class EnrollmentController {
  constructor(private readonly enrollmentService: EnrollmentService) {}

  @Post()
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new course enrollment' })
  @ApiResponse({ status: 201, description: 'Enrollment created successfully', type: CourseEnrollment })
  @ApiResponse({ status: 400, description: 'Invalid input or already enrolled' })
  @ApiResponse({ status: 404, description: 'Course not found' })
  create(@Body() createEnrollmentDto: CreateEnrollmentDto) {
    return this.enrollmentService.create(createEnrollmentDto);
  }

  @Get('course/:courseId')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all enrollments for a course' })
  @ApiParam({ name: 'courseId', description: 'ID of the course', example: '687dfbe86be859bf15944437' })
  @ApiQuery({ name: 'status', required: false, enum: ['approved', 'rejected', 'pending'], description: 'Filter by status' })
  @ApiResponse({ status: 200, description: 'List of enrollments', type: [CourseEnrollment] })
  @ApiResponse({ status: 400, description: 'Invalid course ID' })
  @ApiResponse({ status: 404, description: 'Course not found' })
  findAllByCourse(@Param('courseId') courseId: string, @Query('status') status?: string) {
    return this.enrollmentService.findAllByCourse(courseId, status);
  }

  @Get('my-enrollments')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all enrollments for the authenticated student' })
  @ApiQuery({ name: 'status', required: false, enum: ['approved', 'rejected', 'pending'], description: 'Filter by status' })
  @ApiResponse({ status: 200, description: 'List of enrollments', type: [CourseEnrollment] })
  @ApiResponse({ status: 400, description: 'Invalid user' })
  findAllByStudent(@Query('status') status?: string) {
    return this.enrollmentService.findAllByStudent(status);
  }

  @Get('find-one/:id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get an enrollment by ID' })
  @ApiParam({ name: 'id', description: 'ID of the enrollment', example: '687dfbe86be859bf15944442' })
  @ApiResponse({ status: 200, description: 'Enrollment details', type: CourseEnrollment })
  @ApiResponse({ status: 400, description: 'Invalid enrollment ID' })
  @ApiResponse({ status: 404, description: 'Enrollment not found' })
  findOne(@Param('id') id: string) {
    return this.enrollmentService.findOne(id);
  }

  @Put(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update an enrollment' })
  @ApiParam({ name: 'id', description: 'ID of the enrollment', example: '687dfbe86be859bf15944442' })
  @ApiResponse({ status: 200, description: 'Updated enrollment', type: CourseEnrollment })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 403, description: 'Unauthorized to update this enrollment' })
  @ApiResponse({ status: 404, description: 'Enrollment not found' })
  update(@Param('id') id: string, @Body() updateEnrollmentDto: UpdateEnrollmentDto) {
    // return this.enrollmentService.update(id, updateEnrollmentDto);
  }

  @Put(':id/status')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Approve or reject an enrollment (admin only)' })
  @ApiParam({ name: 'id', description: 'ID of the enrollment', example: '687dfbe86be859bf15944442' })
  @ApiQuery({ name: 'status', required: true, enum: ['approved', 'rejected'], description: 'New status' })
  @ApiResponse({ status: 200, description: 'Updated enrollment', type: CourseEnrollment })
  @ApiResponse({ status: 400, description: 'Invalid enrollment ID or status' })
  @ApiResponse({ status: 404, description: 'Enrollment not found' })
  setStatus(@Param('id') id: string, @Query('status') status: 'approved' | 'rejected') {
    return this.enrollmentService.setStatus(id, status);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete an enrollment' })
  @ApiParam({ name: 'id', description: 'ID of the enrollment', example: '687dfbe86be859bf15944442' })
  @ApiResponse({ status: 200, description: 'Enrollment deleted', type: Object })
  @ApiResponse({ status: 400, description: 'Invalid enrollment ID' })
  @ApiResponse({ status: 403, description: 'Unauthorized to delete this enrollment' })
  @ApiResponse({ status: 404, description: 'Enrollment not found' })
  remove(@Param('id') id: string) {
    return this.enrollmentService.remove(id);
  }

  @Get('count/:courseId')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Count enrollments for a course' })
  @ApiParam({ name: 'courseId', description: 'ID of the course', example: '687dfbe86be859bf15944437' })
  @ApiQuery({ name: 'status', required: false, enum: ['approved', 'rejected', 'pending'], description: 'Filter by status' })
  @ApiResponse({ status: 200, description: 'Number of enrollments', type: Number })
  @ApiResponse({ status: 400, description: 'Invalid course ID' })
  @ApiResponse({ status: 404, description: 'Course not found' })
  countByCourse(@Param('courseId') courseId: string, @Query('status') status?: string) {
    return this.enrollmentService.countByCourse(courseId, status);
  }

    @Get('enrollments-for-teacher')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Find all enrollments for teacher. Teacher can approve disapprove and delete the enrollments' })
  @ApiQuery({ name: 'status', required: false, enum: ['approved', 'rejected', 'pending'], description: 'Filter by status' })
  findEnrollmentsForTeacher(@Query('status') status?: string) {
    return this.enrollmentService.findEnrollmentsForTeacher(status);
  }
}