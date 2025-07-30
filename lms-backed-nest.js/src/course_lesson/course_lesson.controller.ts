import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { CourseLessonService } from './course_lesson.service';
import { CourseLesson } from 'src/schema/course_lesson.schema';
import { CreateCourseLessonDto } from './create-course-lesson.dto';
import { UpdateCourseLessonDto } from './update-course-lesson.dto';
import { ApiBody, ApiConsumes } from '@nestjs/swagger';
import { InterceptorsConsumer } from '@nestjs/core/interceptors';
import { FileInterceptor } from '@nestjs/platform-express';
import { multerOptions } from 'src/config/multer.config';

@Controller('/lessons')
export class CourseLessonController {
  constructor(private readonly lessonService: CourseLessonService) { }

  @Post("/:courseId")
  @HttpCode(HttpStatus.CREATED)
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor("pdfUrl", multerOptions))
  @ApiBody({
    type: CreateCourseLessonDto,
    description: "Create a new course lesson",
  })
  async create(
    @Param('courseId') courseId: string,
    @Body() createCourseLessonDto: CreateCourseLessonDto,
    @UploadedFile() pdfUrl: Express.Multer.File,
    // @Fileup
  ): Promise<CourseLesson> {
        if (!pdfUrl) {
      throw new BadRequestException('PDF file is required');
    }

    if (!pdfUrl.mimetype.includes('pdf')) {
      throw new BadRequestException('Only PDF files are allowed');
    }

    return this.lessonService.create(createCourseLessonDto, courseId, pdfUrl);
  }

  @Get(":courseId")
  async findAllByCourse(
    @Param('courseId') courseId: string,
  ): Promise<CourseLesson[]> {
    return this.lessonService.findAllByCourse(courseId);
  }

  @Get(':lessonId')
  async findOne(
    @Param('lessonId') lessonId: string,
  ): Promise<CourseLesson> {
    return this.lessonService.findOne(lessonId);
  }

  @Put(':lessonId')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor("pdfUrl", multerOptions))
  @ApiBody({
    type: UpdateCourseLessonDto,
    description: "Update a course lesson",
  })
  async update(
    @Param('lessonId') lessonId: string,
    @Body() updateCourseLessonDto: UpdateCourseLessonDto,
    @UploadedFile() pdfUrl?: Express.Multer.File
  ): Promise<CourseLesson> {
      // Additional file validation if needed
    if (pdfUrl && !pdfUrl.mimetype.includes('pdf')) {
      throw new BadRequestException('Only PDF files are allowed');
    }
    return this.lessonService.update(lessonId, updateCourseLessonDto, pdfUrl);
  }

  @Delete(':lessonId')
  async remove(
    @Param('lessonId',) lessonId: string,
  ): Promise<{ deleted: boolean; message?: string }> {
    return this.lessonService.remove(lessonId);
  }
}