import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { HydratedDocument, Types } from "mongoose";
import { Course } from "./course.schema";

export type CourseLessonDocument = HydratedDocument<CourseLesson>;

@Schema({ timestamps: true })
export class CourseLesson {
  @Prop({ required: true })
  title: string;

  @Prop({ required: true })
  description: string;

  @Prop({ required: true })
  pdfUrl: string; // URL to the PDF file

  @Prop()
  pages?: number; // Optional page count

  @Prop()
  readingDuration?: number; // Estimated reading time in minutes

  @Prop({ type: Types.ObjectId, ref: 'Course', required: true })
  course: Course;

  @Prop({ type: [String] })
  keywords?: string[]; // Optional tags for the lesson

  @Prop({ type: [{ type: Types.ObjectId, ref: 'LessonTest' }] })
  tests?: Types.ObjectId[]; // Array of LessonTest references
}

export const courseLessonSchema = SchemaFactory.createForClass(CourseLesson);