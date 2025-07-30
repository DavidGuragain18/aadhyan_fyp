import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { User } from "./user.schema";
import { HydratedDocument, Types } from "mongoose";
import { CourseLesson, courseLessonSchema } from "./course_lesson.schema";

export type CourseDocument = HydratedDocument<Course>

@Schema()
export class Course {
  @Prop()
  title: string;

  @Prop()
  description: string;

  @Prop()
  image?: string;

  // Array of embedded lesson documents
  @Prop({ type: [{ type: Types.ObjectId, ref: 'CourseLesson' }], required: true })
  lessons: Types.ObjectId[];

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  teacher: User;

  @Prop({ type: [{ type: Types.ObjectId, ref: 'CourseReview' }] })
  reviews: Types.ObjectId[];

  @Prop({ type: [{ type: Types.ObjectId, ref: 'CourseTest' }] })
  tests: Types.ObjectId[];

}

export const courseSchema = SchemaFactory.createForClass(Course);