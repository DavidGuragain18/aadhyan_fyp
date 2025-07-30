import { Module } from '@nestjs/common';
import { CourseLessonService } from './course_lesson.service';
import { CourseLessonController } from './course_lesson.controller';
import { Mongoose } from 'mongoose';
import { MongooseModule } from '@nestjs/mongoose';
import { CourseLesson, courseLessonSchema } from 'src/schema/course_lesson.schema';
import { UserSchema } from 'src/schema/user.schema';
import { CourseModule } from 'src/course/course.module';

@Module({
    controllers:[CourseLessonController],
    providers: [CourseLessonService],
    imports:[
          MongooseModule.forFeature([{ name: CourseLesson.name, schema: courseLessonSchema }]), 
          CourseModule,  
    ],
    exports:[
        MongooseModule
    ]
})
export class CourseLessonModule {

}
