import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsMongoId, IsArray, ArrayMinSize, ValidateNested, IsInt } from 'class-validator';
import { Type } from 'class-transformer';

class QuestionDto {
  @ApiProperty({
    description: 'The question text',
    example: 'What is TypeScript?',
    required: true,
    type: String,
  })
  @IsString()
  @IsNotEmpty()
  question: string;

  @ApiProperty({
    description: 'Array of answer options for the question',
    example: ['A JavaScript superset', 'A CSS framework', 'A database', 'A server'],
    required: true,
    type: [String],
    minItems: 2,
  })
  @IsArray()
  @ArrayMinSize(2, { message: 'Each question must have at least 2 options' })
  @IsString({ each: true })
  options: string[];
}

export class CreateTestDto {
  @ApiProperty({
    description: 'The title of the test',
    example: 'Introduction to TypeScript Test',
    required: true,
    type: String,
  })
  @IsString()
  @IsNotEmpty()
  readonly title: string;

  @ApiProperty({
    description: 'The ID of the course this test belongs to',
    example: '687dfbe86be859bf15944438',
    required: true,
    type: String,
  })
  @IsMongoId()
  @IsNotEmpty()
  readonly course: string; // course id

  @ApiProperty({
    description: 'Array of questions for the test',
    type: () => [QuestionDto],
    required: true,
  })
  @IsArray()
  @ArrayMinSize(1, { message: 'At least one question is required' })
  @ValidateNested({ each: true })
  @Type(() => QuestionDto)
  readonly questions: QuestionDto[];

  @ApiProperty({
    description: 'Array of indices indicating the correct answer for each question',
    example: 0,
    required: true,
    type: Number,
  })
  @IsInt()
  readonly correctAnswer: number;
}