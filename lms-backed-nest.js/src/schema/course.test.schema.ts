import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { HydratedDocument, Types } from "mongoose";
import { Course } from "./course.schema";

export type CourseTestDocument = HydratedDocument<CourseTest>;

@Schema({ timestamps: true })
export class CourseTest {
  @Prop({ required: true })
  title: string;

  @Prop({ type: Types.ObjectId, ref: 'Course', required: true })
  course: Types.ObjectId | Course;

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

export const CourseTestSchema = SchemaFactory.createForClass(CourseTest);
