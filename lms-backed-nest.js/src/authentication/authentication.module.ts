import { MiddlewareConsumer, Module, NestModule, RequestMethod } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { AuthenticationService } from './authentication.service';
import { AuthenticationController } from './authentication.controller';
import { User, UserSchema } from '../schema/user.schema';  // Correct path
import { NestApplication } from '@nestjs/core';
import { AuthMiddleware } from 'src/middleware/auth.middleware';

@Module({
  imports: [
    JwtModule.register({
      global: true,
      secret: 'your-secret-key', // Always use env variables in production
      privateKey: "private",
      signOptions: { expiresIn: '1d' }, // Token expires in 1 day
    }),
    MongooseModule.forFeature([{ name: User.name, schema: UserSchema }]),    
  ],
  providers: [AuthenticationService, JwtService],
  controllers: [AuthenticationController],
})

export class AuthenticationModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(AuthMiddleware)
      .forRoutes(
        { path: 'authentication/me', method: RequestMethod.PUT },
        {method: RequestMethod.PUT, path: 'authentication/add-token'},
      );
  }
}