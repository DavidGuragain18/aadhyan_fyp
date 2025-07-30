import { Inject, Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { REQUEST } from '@nestjs/core';
import { Request } from 'express';
import { CourseEnrollment, CourseEnrollmentDocument } from 'src/schema/course_enrollment.schema';
import { Course, CourseDocument } from 'src/schema/course.schema';
import { User, UserDocument } from 'src/schema/user.schema';
import { CreateEnrollmentDto } from './create_enrollment.dto';
import { UpdateEnrollmentDto } from './update_enrollment_dto';

@Injectable({  })
export class EnrollmentService {
  constructor(
    @Inject(REQUEST) private readonly request: Request,
    @InjectModel(CourseEnrollment.name)
    private readonly enrollmentModel: Model<CourseEnrollmentDocument>,
    @InjectModel(Course.name)
    private readonly courseModel: Model<CourseDocument>,
    @InjectModel(User.name)
    private readonly userModel: Model<UserDocument>,
  ) {}

  /**
   * Create a new course enrollment
   */
  async create(createEnrollmentDto: CreateEnrollmentDto): Promise<CourseEnrollment> {
    const user = this.request.user;
    if (!user || !Types.ObjectId.isValid(user.sub)) {
      throw new BadRequestException('Invalid user in request');
    }

    if (!Types.ObjectId.isValid(createEnrollmentDto.courseId)) {
      throw new BadRequestException('Invalid course ID');
    }

    const course = await this.courseModel.findById(createEnrollmentDto.courseId).lean();
    if (!course) {
      throw new NotFoundException('Course not found');
    }

    const existingEnrollment = await this.enrollmentModel
      .findOne({ courseId: createEnrollmentDto.courseId, studentId: user.sub })
      .lean();

    if (existingEnrollment) {
      throw new BadRequestException('You are already enrolled in this course');
    }

    const enrollment = new this.enrollmentModel({
      studentId: user.sub,
      courseId: createEnrollmentDto.courseId,
      status: 'pending',
      completedChapters: [],
    });
    const savedEnrollment = await enrollment.save();

    await this.courseModel.findByIdAndUpdate(
      createEnrollmentDto.courseId,
      { $addToSet: { enrollments: savedEnrollment._id } },
      { new: true },
    );

    await this.userModel.findByIdAndUpdate(
      user._id,
      { $addToSet: { enrollments: savedEnrollment._id } },
      { new: true },
    );

    return savedEnrollment.populate('courseId studentId');
  }

  /**
   * Find all enrollments for a course
   */
  async findAllByCourse(courseId: string, status?: string): Promise<CourseEnrollment[]> {
    if (!Types.ObjectId.isValid(courseId)) {
      throw new BadRequestException('Invalid course ID');
    }

    const course = await this.courseModel.findById(courseId).lean();
    if (!course) {
      throw new NotFoundException('Course not found');
    }

    const query: any = { courseId };
    if (status) {
      if (!['approved', 'rejected', 'pending'].includes(status)) {
        throw new BadRequestException('Invalid status');
      }
      query.status = status;
    }

    return this.enrollmentModel
      .find(query)
      .populate('courseId studentId', 'title name email')
      .lean();
  }

  /**
   * Find all enrollments for the authenticated student
   */
  async findAllByStudent(status?: string): Promise<CourseEnrollment[]> {
    const user = this.request.user;
    if (!user || !Types.ObjectId.isValid(user.sub)) {
      throw new BadRequestException('Invalid user in request');
    }

    const query: any = { studentId: user.sub };
    if (status) {
      if (!['approved', 'rejected', 'pending'].includes(status)) {
        throw new BadRequestException('Invalid status');
      }
      query.status = status;
    }

    return this.enrollmentModel
      .find(query)
      .populate('courseId studentId', 'title name email')
      .lean();
  }

  /**
   * Find a single enrollment by ID
   */
  async findOne(id: string): Promise<CourseEnrollment> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid enrollment ID');
    }

    const enrollment = await this.enrollmentModel
      .findById(id)
      .populate('courseId studentId', 'title name email')
      .lean();

    if (!enrollment) {
      throw new NotFoundException('Enrollment not found');
    }

    return enrollment;
  }

  /**
   * Update an enrollment (e.g., status or completed chapters)
   */
//   async update(id: string, updateEnrollmentDto: UpdateEnrollmentDto): Promise<CourseEnrollment> {
//     const user = this.request.user;
//     if (!user || !Types.ObjectId.isValid(user.sub)) {
//       throw new BadRequestException('Invalid user in request');
//     }

//     if (!Types.ObjectId.isValid(id)) {
//       throw new BadRequestException('Invalid enrollment ID');
//     }

//     const enrollment = await this.enrollmentModel.findById(id).lean();
//     if (!enrollment) {
//       throw new NotFoundException('Enrollment not found');
//     }

//     // Restrict updates to the enrollment's student or admin
//     if (enrollment.studentId.toString() !== user._id.toString()) {
//       throw new ForbiddenException('You are not authorized to update this enrollment');
//     }


//     if (updateEnrollmentDto.status && !['approved', 'rejected', 'pending'].includes(updateEnrollmentDto.status)) {
//       throw new BadRequestException('Invalid status');
//     }
//     if (updateEnrollmentDto.completedChapters) {
//       const course = await this.courseModel.findById(enrollment.courseId).lean();
//       if (course.lessons && updateEnrollmentDto.completedChapters.some(index => index >= course.lessons.length)) {
//         throw new BadRequestException('Invalid chapter index');
//       }
//     }

//     const updatedEnrollment = await this.enrollmentModel
//       .findByIdAndUpdate(id, { $set: updateEnrollmentDto }, { new: true })
//       .populate('courseId studentId', 'title name email')
//       .lean();

//     if (!updatedEnrollment) {
//       throw new NotFoundException('Enrollment not found');
//     }

//     return updatedEnrollment;
//   }

  /**
   * Approve or reject an enrollment (admin only)
   */
  async setStatus(id: string, status: 'approved' | 'rejected'): Promise<CourseEnrollment> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid enrollment ID');
    }

    if (!['approved', 'rejected'].includes(status)) {
      throw new BadRequestException('Invalid status');
    }

    const enrollment = await this.enrollmentModel
      .findByIdAndUpdate(id, { $set: { status } }, { new: true })
      .populate('courseId studentId', 'title name email')
      .lean();

    if (!enrollment) {
      throw new NotFoundException('Enrollment not found');
    }

    return enrollment;
  }

  /**
   * Delete an enrollment
   */
  async remove(id: string): Promise<{ deleted: boolean; message: string }> {
    const user = this.request.user;
    if (!user || !Types.ObjectId.isValid(user.sub)) {
      throw new BadRequestException('Invalid user in request');
    }

    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid enrollment ID');
    }

    const enrollment = await this.enrollmentModel.findById(id).lean();
    if (!enrollment) {
      throw new NotFoundException('Enrollment not found');
    }

    // Restrict deletion to the enrollment's student or admin
    if (enrollment.studentId.toString() !== user.sub.toString()) {
      throw new ForbiddenException('You are not authorized to delete this enrollment');
    }

    await this.enrollmentModel.findByIdAndDelete(id);

    await this.courseModel.findByIdAndUpdate(enrollment.courseId, { $pull: { enrollments: id } });
    await this.userModel.findByIdAndUpdate(enrollment.studentId, { $pull: { enrollments: id } });

    return { deleted: true, message: 'Enrollment deleted successfully' };
  }

  /**
   * Count enrollments for a course
   */
  async countByCourse(courseId: string, status?: string): Promise<number> {
    if (!Types.ObjectId.isValid(courseId)) {
      throw new BadRequestException('Invalid course ID');
    }

    const course = await this.courseModel.findById(courseId).lean();
    if (!course) {
      throw new NotFoundException('Course not found');
    }

    const query: any = { courseId };
    if (status) {
      if (!['approved', 'rejected', 'pending'].includes(status)) {
        throw new BadRequestException('Invalid status');
      }
      query.status = status;
    }

    return this.enrollmentModel.countDocuments(query);
  }


  async findEnrollmentsForTeacher(status?: string): Promise<CourseEnrollment[]> {
    const user = this.request.user;


    // Validate teacher role
  
    // Find courses taught by the user
    const courses = await this.courseModel
      .find({ teacher: user.sub }) // Ensure _id is treated as ObjectId
      .select('_id')
      .lean();

    console.log('Courses found:', courses); // Debug: Log courses

    if (!courses.length) {
      console.log('No courses found for teacher:', user._id);
      return []; // No courses found for the teacher
    }

    const courseIds = courses.map(course => course._id.toString());
    console.log('Course IDs:', courseIds); // Debug: Log course IDs

    const query: any = { courseId: { $in: courseIds } };

    // Apply status filter if provided
    if (status) {
      if (!['approved', 'rejected', 'pending'].includes(status)) {
        throw new BadRequestException('Invalid status. Must be one of: approved, rejected, pending');
      }
      query.status = status;
    }
    console.log('Query:', query); // Debug: Log the final query

    const enrollments = await this.enrollmentModel
      .find(query)
      .populate('courseId studentId', 'title name email')
      .lean();

    console.log('Enrollments found:', enrollments); // Debug: Log enrollments
    return enrollments;
  }
  
}