import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { NotificationController } from './notification.controller';
import { NotificationService } from './notification.service';
import { MongooseModule } from '@nestjs/mongoose';
import { Notification, notificationSchema } from 'src/schema/notification.schema';
import { CourseEnrollment, courseEnrollmentSchema } from 'src/schema/course_enrollment.schema';
import { Course, courseSchema,  } from 'src/schema/course.schema';
import { AuthMiddleware } from 'src/middleware/auth.middleware';

@Module({
  controllers: [NotificationController],
  providers: [NotificationService],
  imports: [
    MongooseModule.forFeature([
      { name: Notification.name, schema: notificationSchema },
      { name: CourseEnrollment.name, schema: courseEnrollmentSchema },
      { name: Course.name, schema: courseSchema }
    ]),
  ]
})
export class NotificationModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(AuthMiddleware)
      .forRoutes(NotificationController);
  }
}