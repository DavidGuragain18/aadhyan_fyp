import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { EnrollmentController } from './enrollment.controller';
import { EnrollmentService } from './enrollment.service';
import { AuthMiddleware } from 'src/middleware/auth.middleware';
import { MongooseModule } from '@nestjs/mongoose';
import { CourseEnrollment, courseEnrollmentSchema } from 'src/schema/course_enrollment.schema';
import { Course, courseSchema } from 'src/schema/course.schema';
import { User, UserSchema } from 'src/schema/user.schema';

@Module({
  controllers: [EnrollmentController],
  providers: [EnrollmentService],
  imports:[
    MongooseModule.forFeature([
      { name: CourseEnrollment.name, schema: courseEnrollmentSchema },
      { name: Course.name, schema: courseSchema },
      { name: User.name, schema: UserSchema },
    ])
  ]
})

export class EnrollmentModule implements NestModule{
  configure(consumer: MiddlewareConsumer) {
   consumer.apply(AuthMiddleware).forRoutes(EnrollmentController);
  }

}
