import { IsArray, IsMongoId, IsNotEmpty, IsOptional, IsString, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';
import { CourseLesson } from 'src/schema/course_lesson.schema'; // Adjust path as needed
import { MulterField } from '@nestjs/platform-express/multer/interfaces/multer-options.interface';


// Main DTO for creating a course
export class CreateCourseDto {
  @ApiProperty({
    description: 'The title of the course',
    example: 'Introduction to TypeScript',
  })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({
    description: 'A brief description of the course',
    example: 'A beginner-friendly course on TypeScript fundamentals.',
  })
  @IsString()
  @IsNotEmpty()
  description: string;

  @ApiProperty({
    type: 'string',
    format: 'binary',
    description: 'Course cover image file',
    required: false,
  })
  @IsOptional()
  
  coverImage?: MulterField;

}