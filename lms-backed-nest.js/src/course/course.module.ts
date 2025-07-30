import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { CourseController } from './course.controller';
import { CourseService } from './course.service';
import { MongooseModule } from '@nestjs/mongoose';
import { Course, courseSchema } from 'src/schema/course.schema';
import { AuthMiddleware } from 'src/middleware/auth.middleware';

@Module({
  controllers: [CourseController],
  providers: [CourseService],
  imports: [
    MongooseModule.forFeature([{ name: Course.name, schema: courseSchema }]),
  ],
  exports: [
    MongooseModule
  ]
})
export class CourseModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(AuthMiddleware).forRoutes(CourseController);
  }


}
