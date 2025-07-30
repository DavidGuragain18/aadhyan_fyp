import { ApiProperty } from '@nestjs/swagger';
import { NotificationStatus, NotificationType } from '../schema/notification.schema';
import { IsEnum, IsNotEmpty, IsString, IsMongoId, IsOptional, IsUrl } from 'class-validator';

export class CreateTestNotificationDto {
  @ApiProperty({
    description: 'ID of the course this notification belongs to',
    example: '507f1f77bcf86cd799439011'
  })
  @IsNotEmpty()
  courseId: string;

  @ApiProperty({
    description: 'Title of the notification',
    example: 'New Course Update'
  })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({
    description: 'Body content of the notification',
    example: 'A new lesson has been added to your course'
  })
  @IsString()
  @IsNotEmpty()
  body: string;


  @ApiProperty({
    enum: NotificationStatus,
    description: 'Status of the notification',
    example: NotificationStatus.SENT
  })
  @IsEnum(NotificationStatus)
  @IsNotEmpty()
  status: NotificationStatus;

  @ApiProperty({
    enum: NotificationType,
    description: 'Type of the notification',
    example: NotificationType.TEST
  })
  @IsEnum(NotificationType)
  @IsNotEmpty()
  type: NotificationType;
}