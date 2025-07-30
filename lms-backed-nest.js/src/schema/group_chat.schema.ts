import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { HydratedDocument, Types } from "mongoose";
import { LessonTest } from "./lesson.test.schema";
import { Course } from "./course.schema";
import { User } from "./user.schema";

export type GroupChatDocument = HydratedDocument<LessonTest>;

@Schema({timestamps: true})
export class GroupChat{
    @Prop({required: true})
    message: string;

    @Prop({ type: [{ type: Types.ObjectId, ref: 'User' }], required: true })
    user: User;

    @Prop({ type: [{  type: Types.ObjectId, ref: 'Courses' }], required: true })
    course: Course
}

export const GroupChatSchema = SchemaFactory.createForClass(GroupChat);