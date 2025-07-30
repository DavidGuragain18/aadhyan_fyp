import { Injectable, NotFoundException, BadRequestException, Inject } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Course, CourseDocument } from 'src/schema/course.schema';
import { CreateReviewDto } from './create_review.dto';
import { CourseReview, CourseReviewDocument } from 'src/schema/course_reviews';
import { UpdateReviewDto } from './update_review.dto';
import { REQUEST } from '@nestjs/core';
import { Request } from 'express';


@Injectable()
export class CourseReviewService {
    constructor(
        @InjectModel(CourseReview.name)
        private readonly reviewModel: Model<CourseReviewDocument>,
        @InjectModel(Course.name)
        private readonly courseModel: Model<CourseDocument>,
        @Inject(REQUEST) private request: Request,
    ) { }

    /**
     * Create a new course review and associate it with a course
     */
    async create(createReviewDto: CreateReviewDto): Promise<CourseReview> {
        // Validate DTO
        if (!Types.ObjectId.isValid(createReviewDto.course)) {
            throw new BadRequestException('Invalid course ID');
        }

        if (createReviewDto.rating < 1 || createReviewDto.rating > 5) {
            throw new BadRequestException('Rating must be between 1 and 5');
        }

        // Verify course exists
        const course = await this.courseModel.findById(createReviewDto.course).lean();
        if (!course) {
            throw new NotFoundException('Course not found');
        }

        console.log(this.request.user);
        

        // Check if user has already reviewed this course
        const existingReview = await this.reviewModel
            .findOne({ course: createReviewDto.course, user: this.request.user.sub })
            .lean();
        if (existingReview) {
            throw new BadRequestException('User has already reviewed this course');
        }

        // Create review
        const review = new this.reviewModel({
            ...createReviewDto,
            user: this.request.user.sub,
            isApproved: false, // Default to unapproved
        });
        const savedReview = await review.save();

        // Update course with review reference
        await this.courseModel.findByIdAndUpdate(
            createReviewDto.course,
            { $addToSet: { reviews: savedReview._id } },
            { new: true },
        );

        return savedReview;
    }

    /**
     * Find all reviews for a given course
     */
    async findAllByCourse(courseId: string): Promise<CourseReview[]> {
        if (!Types.ObjectId.isValid(courseId)) {
            throw new BadRequestException('Invalid course ID');
        }

        const course = await this.courseModel
            .findById(courseId)
            .populate<{ reviews: CourseReview[] }>({
                path: 'reviews',
                populate: { path: 'user', select: 'name email' },
            })
            .lean();

        if (!course) {
            throw new NotFoundException('Course not found');
        }

        return course.reviews || [];
    }

    /**
     * Find all reviews (optionally filtered by approval status)
     */
    async findAll(approvedOnly: boolean = true): Promise<CourseReview[]> {
        const query = approvedOnly ? { isApproved: true } : {};
        return this.reviewModel
            .find(query)
            .populate('course user', 'title name email')
            .lean();
    }

    /**
     * Find a single review by ID
     */
    async findOne(id: string): Promise<CourseReview> {
        if (!Types.ObjectId.isValid(id)) {
            throw new BadRequestException('Invalid review ID');
        }

        const review = await this.reviewModel
            .findById(id)
            .populate('course user', 'title name email')
            .lean();

        if (!review) {
            throw new NotFoundException('Review not found');
        }

        return review;
    }

    /**
     * Update a review by ID
     */
    async update(id: string, updateReviewDto: UpdateReviewDto): Promise<CourseReview> {
        if (!Types.ObjectId.isValid(id)) {
            throw new BadRequestException('Invalid review ID');
        }

        // Validate DTO if provided
        if (updateReviewDto.rating && (updateReviewDto.rating < 1 || updateReviewDto.rating > 5)) {
            throw new BadRequestException('Rating must be between 1 and 5');
        }

        // Check if course exists if provided
        if (updateReviewDto.course) {
            if (!Types.ObjectId.isValid(updateReviewDto.course)) {
                throw new BadRequestException('Invalid course ID');
            }
            const course = await this.courseModel.findById(updateReviewDto.course).lean();
            if (!course) {
                throw new NotFoundException('Course not found');
            }
        }

        // Update review
        const review = await this.reviewModel
            .findByIdAndUpdate(id, { $set: updateReviewDto }, { new: true })
            .populate('course user', 'title name email')
            .lean();

        if (!review) {
            throw new NotFoundException('Review not found');
        }

        // If course ID changed, update course references
        if (updateReviewDto.course && review.course.toString() !== updateReviewDto.course) {
            await this.courseModel.findByIdAndUpdate(review.course, { $pull: { reviews: id } });
            await this.courseModel.findByIdAndUpdate(updateReviewDto.course, { $addToSet: { reviews: id } });
        }

        return review;
    }

   

    /**
     * Delete a review by ID
     */
    async remove(id: string): Promise<{ deleted: boolean; message: string }> {
        if (!Types.ObjectId.isValid(id)) {
            throw new BadRequestException('Invalid review ID');
        }

        const review = await this.reviewModel.findByIdAndDelete(id).lean();
        if (!review) {
            throw new NotFoundException('Review not found');
        }

        // Remove review reference from course
        await this.courseModel.findByIdAndUpdate(review.course, { $pull: { reviews: id } });

        return { deleted: true, message: 'Review deleted successfully' };
    }

    /**
     * Count reviews for a given course
     */
    async countByCourse(courseId: string, approvedOnly: boolean = true): Promise<number> {
        if (!Types.ObjectId.isValid(courseId)) {
            throw new BadRequestException('Invalid course ID');
        }

        const course = await this.courseModel.findById(courseId).lean();
        if (!course) {
            throw new NotFoundException('Course not found');
        }

        const query = approvedOnly ? { course: courseId, isApproved: true } : { course: courseId };
        return this.reviewModel.countDocuments(query);
    }
}