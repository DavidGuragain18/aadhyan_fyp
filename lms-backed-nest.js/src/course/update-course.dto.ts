// update-course.dto.ts
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsArray, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { CourseLesson } from 'src/schema/course_lesson.schema';

export class UpdateCourseDto {
  @ApiPropertyOptional({
    example: 'Advanced JavaScript',
    description: 'The title of the course',
  })
  @IsString()
  @IsOptional()
  title?: string;

  @ApiPropertyOptional({
    example: 'This course covers advanced JavaScript concepts.',
    description: 'Detailed description of the course',
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({
    type: 'string',
    format: 'binary',
    description: 'Optional cover image for the course',
  })
  @IsOptional()
  coverImage?: any; // Use `any` because file is handled by Multer

 

}


