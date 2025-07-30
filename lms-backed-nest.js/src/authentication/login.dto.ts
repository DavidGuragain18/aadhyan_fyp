// login.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString } from 'class-validator';

export class LoginDto {
  @ApiProperty({
    required: true,
    default: "test@example.com"
  })
  @IsEmail()
  email: string;

 @ApiProperty({
    required: true,
    default: "Password@123"
  })
  @IsString()
  password: string;
}