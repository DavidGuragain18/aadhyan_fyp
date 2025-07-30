import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { HydratedDocument, Types } from "mongoose";
import { Course } from "src/schema/course.schema";
import { User } from "src/schema/user.schema";


export type GroupChatDocument = HydratedDocument<GroupChat>;

@Schema({ timestamps: true })
export class GroupChat {
    @Prop({ required: true })
    message: string;

    @Prop({ type: Types.ObjectId, ref: 'Course', required: true })
    course: Course;

    @Prop({ type: Types.ObjectId, ref: 'User', required: true })
    user: User
}

export const GroupChatSchema = SchemaFactory.createForClass(GroupChat);