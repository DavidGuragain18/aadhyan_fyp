import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsEnum, IsArray, IsInt } from 'class-validator';

export class UpdateEnrollmentDto {
  @ApiProperty({
    description: 'The enrollment status',
    example: 'approved',
    required: false,
    enum: ['approved', 'rejected', 'pending'],
  })
  @IsEnum(['approved', 'rejected', 'pending'])
  @IsOptional()
  readonly status?: string;

  @ApiProperty({
    description: 'Array of completed chapter indices',
    example: [0, 1, 2],
    required: false,
    type: [Number],
  })
  @IsArray()
  @IsInt({ each: true })
  @IsOptional()
  readonly completedChapters?: number[];
}