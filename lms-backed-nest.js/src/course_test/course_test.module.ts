import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { CourseLessonModule } from 'src/course_lesson/course_lesson.module';
import { CourseModule } from 'src/course/course.module';
import { LessonTest, LessonTestSchema } from 'src/schema/lesson.test.schema';
import { CourseTestController } from './course_test.controller';
import { CourseTestService } from './course_test.service';
import { CourseTest, CourseTestSchema } from 'src/schema/course.test.schema';
import { Course, courseSchema } from 'src/schema/course.schema';

@Module({
  controllers: [CourseTestController],
  providers: [CourseTestService],
  imports: [
    MongooseModule.forFeature([
      { name: CourseTest.name, schema: CourseTestSchema },
      { name: Course.name, schema: courseSchema } // Register Course model
    ]),
  ],
})
export class CourseTestModule {}
