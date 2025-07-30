import { Test, TestingModule } from '@nestjs/testing';
import { LessonTestService } from './lesson_test.service';

describe('LessonTestService', () => {
  let service: LessonTestService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [LessonTestService],
    }).compile();

    service = module.get<LessonTestService>(LessonTestService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
