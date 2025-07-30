import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class UpdateUserDto {
  @ApiProperty({
    example: 'Updated Name',
    description: 'New name for the user',
    required: false,
  })
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  name: string;

  @ApiProperty({
    type: 'string',
    format: 'binary',
    required: false,
    description: 'New profile image for the user (optional)',
  })
  file: any

  // Note: For image updates, we'll handle separately via file upload
}