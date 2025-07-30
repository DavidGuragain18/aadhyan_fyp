import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { CourseReviewService } from './course-review.service';
import { CourseReviewController } from './course-review.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { CourseReview, CourseReviewSchema } from 'src/schema/course_reviews';
import { Course, courseSchema } from 'src/schema/course.schema';
import { AuthMiddleware } from 'src/middleware/auth.middleware';

@Module({
  providers: [CourseReviewService],
  controllers: [CourseReviewController],
  imports: [
    MongooseModule.forFeature([
      { name: CourseReview.name, schema: CourseReviewSchema },
      { name: Course.name, schema: courseSchema },
    ]),
  ],
})
export class CourseReviewModule implements NestModule{
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(AuthMiddleware).forRoutes(CourseReviewController);
  }
}