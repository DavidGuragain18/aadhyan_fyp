import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { GroupChatController } from './group_chat.controller';
import { GroupChatService } from './group_chat.service';
import { MongooseModule } from '@nestjs/mongoose';
import { GroupChat, GroupChatSchema } from './group-chat.schema';
import { User, UserSchema } from 'src/schema/user.schema';
import { NestApplication } from '@nestjs/core';
import { AuthMiddleware } from 'src/middleware/auth.middleware';

@Module({
  controllers: [GroupChatController],
  providers: [GroupChatService],
  imports: [
    MongooseModule.forFeature([{ name: GroupChat.name, schema: GroupChatSchema }, { name: User.name, schema: UserSchema }])
  ]
})
export class GroupChatModule  implements NestModule{
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(AuthMiddleware).forRoutes(GroupChatController);
  }

}
