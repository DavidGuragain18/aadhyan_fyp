import { ApiProperty } from '@nestjs/swagger';
import { NotificationStatus } from '../schema/notification.schema';
import { IsEnum, IsNotEmpty } from 'class-validator';

export class UpdateNotificationStatusDto {
  @ApiProperty({ enum: NotificationStatus })
  @IsEnum(NotificationStatus)
  @IsNotEmpty()
  status: NotificationStatus;
}