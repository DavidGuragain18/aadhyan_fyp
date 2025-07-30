import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MongooseModule } from '@nestjs/mongoose';
import { AuthenticationModule } from './authentication/authentication.module';
import { CourseController } from './course/course.controller';
import { CourseService } from './course/course.service';
import { CourseModule } from './course/course.module';
import { CourseLessonService } from './course_lesson/course_lesson.service';
import { CourseLessonModule } from './course_lesson/course_lesson.module';
import { CourseLessonController } from './course_lesson/course_lesson.controller';
import { LessonTestModule } from './lesson_test/lesson_test.module';
import { UploadModule } from './upload/upload.module';
import { CourseReviewModule } from './course-review/course-review.module';
import { EnrollmentModule } from './enrollment/enrollment.module';
import { GroupChatModule } from './group_chat/group_chat.module';
import { NotificationModule } from './notification/notification.module';
import { CourseTestModule } from './course_test/course_test.module';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';

@Module({
  imports: [
    MongooseModule.forRoot('mongodb://localhost:27017/adhyan'),
    AuthenticationModule,
    CourseModule,
    CourseLessonModule,
    LessonTestModule,
    UploadModule,
    CourseReviewModule,
    EnrollmentModule,
    GroupChatModule,
    NotificationModule,
    CourseTestModule,
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', 'uploads'),
      serveRoot: '/uploads', // optional, this will make files available under /uploads
    }),
  ],
  controllers: [AppController, CourseController, CourseLessonController],
  providers: [AppService, CourseService, CourseLessonService],
})
export class AppModule { }
