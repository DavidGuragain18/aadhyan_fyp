import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MaxLength, MinLength } from 'class-validator';

export class GroupChatDto {
  @ApiProperty({
    example: 'Hello everyone! How are you doing with the course?',
    description: 'The message content for group chat',
    required: true,
    maxLength: 1000,
  })
  @IsNotEmpty({ message: 'Message cannot be empty' })
  @IsString({ message: 'Message must be a string' })
  @MinLength(1, { message: 'Message must be at least 1 character long' })
  @MaxLength(1000, { message: 'Message cannot exceed 1000 characters' })
  message: string;

  @ApiProperty({
    example: '507f1f77bcf86cd799439011',
    description: 'The ID of the course this message belongs to',
    required: true,
  })
  @IsNotEmpty({ message: 'Course ID cannot be empty' })
  @IsString({ message: 'Course ID must be a string' })
  courseId: string;
}