import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Query, UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiQuery,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { NotificationService } from './notification.service';
import { NotificationType } from '../schema/notification.schema';
import { CreateNotificationDto } from './create-notification.dto';
import { UpdateNotificationStatusDto } from './update-notification-status.dto';
import { CreateTestNotificationDto } from './create_test_notification.dto';

@ApiTags('Notifications')
@ApiBearerAuth()
@Controller('notifications')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) { }

  @Post()
  @ApiOperation({ summary: 'Create a new notification' })
  @ApiResponse({ status: 201, description: 'Notification created successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async create(@Body() createNotificationDto: CreateNotificationDto) {
    return this.notificationService.createNotification(
      createNotificationDto.title,
      createNotificationDto.body,
      createNotificationDto.type,
      createNotificationDto.data,
      createNotificationDto.imageUrl,
      createNotificationDto.actionUrl,
    );
  }

  @Post("create-test-notification")
  @ApiOperation({ summary: 'Create a test notifcaiotn' })
  @ApiResponse({ status: 201, description: 'Notification created successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async createTestNotification(@Body() createNotificationDto: CreateTestNotificationDto) {
    return this.notificationService.createTestNotification({
      courseId: createNotificationDto.courseId,
      title: createNotificationDto.title,
      body: createNotificationDto.body,
      status: createNotificationDto.status,
      type: createNotificationDto.type,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get notification by ID' })
  @ApiParam({ name: 'id', description: 'Notification ID' })
  @ApiResponse({ status: 200, description: 'Notification found' })
  @ApiResponse({ status: 404, description: 'Notification not found' })
  async findOne(@Param('id') id: string) {
    return this.notificationService.getNotificationById(id);
  }

  @Get()
  @ApiOperation({ summary: 'Get all notifications for user' })

  @ApiResponse({ status: 200, description: 'Notifications retrieved' })
  async findAll(

  ) {

    // In a real app, you'd get userId from the authenticated user
    return this.notificationService.getUserNotifications();
  }

  @Get('unread/count')
  @ApiOperation({ summary: 'Get count of unread notifications' })
  @ApiResponse({ status: 200, description: 'Unread count returned' })
  async getUnreadCount() {
    const userId = 'user-id-from-token'; // Replace with actual user ID from request
    return this.notificationService.getUnreadNotificationsCount(userId);
  }

  @Put(':id/read')
  @ApiOperation({ summary: 'Mark notification as read' })
  @ApiParam({ name: 'id', description: 'Notification ID' })
  @ApiResponse({ status: 200, description: 'Notification marked as read' })
  @ApiResponse({ status: 404, description: 'Notification not found' })
  async markAsRead(@Param('id') id: string) {
    return this.notificationService.markAsRead(id);
  }

  @Put('read/all')
  @ApiOperation({ summary: 'Mark all notifications as read' })
  @ApiResponse({
    status: 200,
    description: 'Notifications marked as read',
    type: Object,
  })
  async markAllAsRead() {
    const userId = 'user-id-from-token'; // Replace with actual user ID from request
    return this.notificationService.markAllAsRead(userId);
  }

@Put(':id/status')
@ApiOperation({ summary: 'Update notification status for user' })
@ApiParam({ name: 'id', description: 'Notification ID' })
@ApiBody({ type: UpdateNotificationStatusDto })
@ApiResponse({ status: 200, description: 'Status updated' })
@ApiResponse({ status: 404, description: 'Notification not found' })
async updateStatus(
    @Param('id') id: string,
    @Body() updateStatusDto: UpdateNotificationStatusDto,
) {
    return this.notificationService.updateNotificationStatus(
        id,
        updateStatusDto.status
    );
}

  @Delete(':id')
  @ApiOperation({ summary: 'Delete notification' })
  @ApiParam({ name: 'id', description: 'Notification ID' })
  @ApiResponse({ status: 200, description: 'Notification deleted' })
  @ApiResponse({ status: 404, description: 'Notification not found' })
  async remove(@Param('id') id: string) {
    return this.notificationService.deleteNotification(id);
  }

  @Get('type/:type')
  @ApiOperation({ summary: 'Get notifications by type' })
  @ApiParam({ name: 'type', enum: NotificationType })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Notifications by type' })
  async findByType(
    @Param('type') type: NotificationType,
    @Query('limit') limit = 10,
  ) {
    const userId = 'user-id-from-token'; // Replace with actual user ID from request
    return this.notificationService.getNotificationsByType(userId, type, limit);
  }

  @Get('search')
  @ApiOperation({ summary: 'Search notifications' })
  @ApiQuery({ name: 'q', description: 'Search term' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Search results' })
  async search(
    @Query('q') searchTerm: string,
    @Query('limit') limit = 10,
  ) {
    const userId = 'user-id-from-token'; // Replace with actual user ID from request
    return this.notificationService.searchNotifications(userId, searchTerm, limit);
  }
}