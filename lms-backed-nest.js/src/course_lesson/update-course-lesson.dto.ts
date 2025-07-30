import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { 
  IsString, 
  IsOptional, 
  IsInt, 
  Min, 
  MinLength, 
  IsArray, 
  IsNotEmpty, 
  ArrayMinSize, 
  ValidateIf,
  IsNumber,
} from 'class-validator';

export class UpdateCourseLessonDto {
  @ApiProperty({ 
    required: false,
    example: 'Advanced TypeScript Patterns',
    description: 'Title of the lesson'
  })
  @IsOptional()
  @IsString()
  @MinLength(3, { message: 'Title must be at least 3 characters long' })
  readonly title?: string;

  @ApiProperty({ 
    required: false,
    example: 'Deep dive into advanced TypeScript concepts and patterns',
    description: 'Detailed description of the lesson'
  })
  @IsOptional()
  @IsString()
  @MinLength(10, { message: 'Description must be at least 10 characters long' })
  readonly description?: string;

  @ApiProperty({
    type: 'string',
    format: 'binary',
    required: false,
    description: 'PDF file for the lesson (optional)'
  })
  @IsOptional()
  readonly pdfUrl?: any; // Keep as any to handle file or string


  @ApiProperty({ 
    required: false, 
    type: Number,
    example: 30,
    description: 'Estimated reading duration in minutes',
    minimum: 1
  })
  @IsOptional()
  @IsNumber()
  @Min(1, { message: 'Reading duration must be at least 1 minute' })
  @Transform(({ value }) => (typeof value === 'string' ? parseInt(value, 10) : value))
  readonly readingDuration?: number;

  @ApiProperty({ 
    required: false, 
    type: [String],
    example: ['TypeScript', 'Design Patterns'],
    description: 'Array of keywords for the lesson'
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true, message: 'Each keyword must be a string' })
  readonly keywords?: string[];
}