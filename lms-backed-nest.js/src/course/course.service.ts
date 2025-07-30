import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Course, CourseDocument } from '../schema/course.schema';
import { CreateCourseDto } from './create-course.dto';
import { UpdateCourseDto } from './update-course.dto';
import { join } from 'path';
import { existsSync, mkdirSync } from 'fs';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';
import { REQUEST } from '@nestjs/core';

@Injectable()
export class CourseService {
  constructor(
    @InjectModel(Course.name) private courseModel: Model<CourseDocument>,
    @Inject(REQUEST) private request: Request,
    private jwtService: JwtService

    //   @InjectModel(User.name) private userModel: Model<User>,
  ) {
    // Ensure upload directory exists
    const uploadDir = join(__dirname, '../../uploads/course-covers');
    if (!existsSync(uploadDir)) {
      mkdirSync(uploadDir, { recursive: true });
    }
  }

  async create(createCourseDto: CreateCourseDto, coverImage?: Express.Multer.File, ): Promise<Course> {

    let coverImageUrl: string | undefined;

    if (coverImage) {
      // In production, you would upload to Cloudinary/S3 here
      coverImageUrl = `/course-covers/${coverImage.filename}`;
    }
    
    const createdCourse = new this.courseModel({
      ...createCourseDto,
      image: coverImageUrl,
      teacher: this.request.user.sub
    });

    return createdCourse.save();
  }

  async findAll(): Promise<Course[]> {
    return this.courseModel.find().exec();
  }

  async findOne(id: string): Promise<Course> {
    const course = await this.courseModel.findById(id).exec();
    if (!course) {
      throw new NotFoundException('Course not found');
    }
    return course;
  }
  async update(
    id: string,
    updateCourseDto: UpdateCourseDto,
    coverImage?: Express.Multer.File
  ): Promise<Course> {
    let coverImageUrl: string | undefined;

    if (coverImage) {
      coverImageUrl = `/course-covers/${coverImage.filename}`;
    }

    const updatePayload = {
      ...updateCourseDto,
      ...(coverImageUrl && { image: coverImageUrl }), // only adds `image` if defined
    };

    const existingCourse = await this.courseModel
      .findByIdAndUpdate(id, updatePayload, { new: true })
      .exec();

    if (!existingCourse) {
      throw new NotFoundException('Course not found');
    }

    return existingCourse;
  }

  async remove(id: string): Promise<void> {
    const result = await this.courseModel.deleteOne({ _id: id }).exec();
    if (result.deletedCount === 0) {
      throw new NotFoundException('Course not found');
    }
  }
}