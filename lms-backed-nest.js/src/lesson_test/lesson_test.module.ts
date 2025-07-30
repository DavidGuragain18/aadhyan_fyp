import { Module } from '@nestjs/common';
import { LessonTestController } from './lesson_test.controller';
import { LessonTestService } from './lesson_test.service';
import { MongooseModule } from '@nestjs/mongoose';
import { CourseLessonModule } from 'src/course_lesson/course_lesson.module';
import { CourseModule } from 'src/course/course.module';
import { LessonTest, LessonTestSchema } from 'src/schema/lesson.test.schema';

@Module({
  controllers: [LessonTestController],
  providers: [LessonTestService],
  imports: [
     MongooseModule.forFeature([{ name: LessonTest.name, schema: LessonTestSchema }]), 
     CourseModule,  
     CourseLessonModule,
  ]
})
export class LessonTestModule {}
