import { ApiProperty } from '@nestjs/swagger';
import { IsMongoId, IsNotEmpty } from 'class-validator';

export class CreateEnrollmentDto {
  @ApiProperty({
    description: 'The ID of the course',
    example: '687dfbe86be859bf15944437',
    required: true,
    type: String,
  })
  @IsMongoId()
  @IsNotEmpty()
  readonly courseId: string;
}