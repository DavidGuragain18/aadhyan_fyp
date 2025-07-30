import { Test, TestingModule } from '@nestjs/testing';
import { LessonTestController } from './lesson_test.controller';

describe('LessonTestController', () => {
  let controller: LessonTestController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [LessonTestController],
    }).compile();

    controller = module.get<LessonTestController>(LessonTestController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
