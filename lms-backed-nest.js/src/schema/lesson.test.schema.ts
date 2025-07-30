import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { HydratedDocument, Types } from "mongoose";
import { CourseLesson } from "./course_lesson.schema";

export type LessonTestDocument = HydratedDocument<LessonTest>;

@Schema({ timestamps: true })
export class LessonTest {
  @Prop({ required: true })
  title: string;

  @Prop({ type: Types.ObjectId, ref: 'CourseLesson', required: true })
  lesson: CourseLesson;

  @Prop({
    required: true,
    type: [{
      question: { type: String, required: true },
      options: [{ type: String, required: true }],
    }]
  })
  questions: { question: string; options: string[] }[];

  @Prop({ type: Number, required: true })
  correctAnswer: number;
}

export const LessonTestSchema = SchemaFactory.createForClass(LessonTest);
