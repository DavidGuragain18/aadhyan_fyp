import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { Course } from './course.schema';

export type CourseReviewDocument = HydratedDocument<CourseReview>;

@Schema({ timestamps: true })
export class CourseReview {
  @Prop({ type: Types.ObjectId, ref: 'Course', required: true })
  course: Course;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  user: Types.ObjectId;

  @Prop({ required: true, min: 1, max: 5 })
  rating: number;

  @Prop({ required: true, trim: true })
  comment: string;
}

export const CourseReviewSchema = SchemaFactory.createForClass(CourseReview);