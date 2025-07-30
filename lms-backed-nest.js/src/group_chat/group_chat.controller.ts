import { Controller, Get, Post, Body, Param } from '@nestjs/common';

import { ApiBody, ApiOperation, ApiParam, ApiResponse, ApiTags } from '@nestjs/swagger';
import { GroupChatService } from './group_chat.service';
import { GroupChatDto } from './group_chat.dto';

@ApiTags('Group Chat')
@Controller('group-chat')
export class GroupChatController {
  constructor(private readonly groupChatService: GroupChatService) {}

  @Post()
  @ApiOperation({ summary: 'Send a message to group chat' })
  @ApiBody({ type: GroupChatDto })
  @ApiResponse({ status: 201, description: 'Message successfully sent' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  async sendMessage(
    @Body() groupChatDto: GroupChatDto,
  ) {
    return this.groupChatService.sendMessage(
      groupChatDto.message,
      groupChatDto.courseId,
    );
  }

  @Get(':courseId')
  @ApiOperation({ summary: 'Get all messages for a course' })
  @ApiParam({ name: 'courseId', description: 'ID of the course' })
  @ApiResponse({ status: 200, description: 'List of messages' })
  async getMessages(@Param('courseId') courseId: string) {
    return this.groupChatService.getMessages(courseId);
  }
}