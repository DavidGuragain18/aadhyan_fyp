import { Inject, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { GroupChat, GroupChatDocument } from './group-chat.schema';
import { REQUEST } from '@nestjs/core';
import { Request } from 'express';
import { User, UserDocument, UserSchema } from 'src/schema/user.schema';

@Injectable()
export class GroupChatService {
    constructor(
        @InjectModel(GroupChat.name) private groupChatModel: Model<GroupChatDocument>,
        @InjectModel(User.name) private user: Model<UserDocument>,
        @Inject(REQUEST) private request: Request
    ) {}

    async sendMessage(message: string, courseId: string): Promise<GroupChat> {
        const newMessage = new this.groupChatModel({
            message,
            user: this.request.user.sub,
            course: courseId,
        });
        return newMessage.save();
    }

    async getMessages(courseId: string): Promise<GroupChat[]> {
        return this.groupChatModel.find({ course: courseId })
            .populate('user', 'name email') // Populate user details
            .populate('course', 'title')  // Populate course details
            .sort({ createdAt: -1 })     // Sort by latest first
            .exec();
    }
}