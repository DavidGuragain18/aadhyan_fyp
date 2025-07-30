import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { Course } from './course.schema';
import { User } from './user.schema';

export type CourseEnrollmentDocument = HydratedDocument<CourseEnrollment>;

@Schema({ timestamps: true })
export class CourseEnrollment {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  studentId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Course', required: true, index: true })
  courseId: Types.ObjectId;

  @Prop({ required: true, default: Date.now })
  enrolledAt: Date;

  @Prop({ required: true, enum: ['approved', 'rejected', 'pending'], default: 'pending' })
  status: string;

  @Prop({ type: [Number], default: [] })
  completedChapters: number[];
}

export const courseEnrollmentSchema = SchemaFactory.createForClass(CourseEnrollment);