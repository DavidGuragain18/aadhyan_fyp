import { ApiProperty } from '@nestjs/swagger';
import { IsMongoId, IsString, IsInt, Min, Max, IsOptional, IsBoolean } from 'class-validator';

export class UpdateReviewDto {
  @ApiProperty({
    description: 'The ID of the course being reviewed',
    example: '687dfbe86be859bf15944437',
    required: false,
    type: String,
  })
  @IsMongoId()
  @IsOptional()
  readonly course?: string;

  @ApiProperty({
    description: 'The ID of the user submitting the review',
    example: '687dfbe86be859bf15944440',
    required: false,
    type: String,
  })
  @IsMongoId()
  @IsOptional()
  readonly user?: string;

  @ApiProperty({
    description: 'The rating for the course (1 to 5)',
    example: 4,
    required: false,
    type: Number,
  })
  @IsInt()
  @Min(1)
  @Max(5)
  @IsOptional()
  readonly rating?: number;

  @ApiProperty({
    description: 'The review comment',
    example: 'Updated: Great course, very informative!',
    required: false,
    type: String,
  })
  @IsString()
  @IsOptional()
  readonly comment?: string;

  @ApiProperty({
    description: 'Whether the review is approved',
    example: true,
    required: false,
    type: Boolean,
  })
  @IsBoolean()
  @IsOptional()
  readonly isApproved?: boolean;
}