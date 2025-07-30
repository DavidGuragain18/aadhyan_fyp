import { ConflictException, Inject, Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';
import { User } from 'src/schema/user.schema';
import { REQUEST } from '@nestjs/core';
import { Request } from 'express';

@Injectable()
export class AuthenticationService {
  constructor(
    private readonly jwtService: JwtService, // Inject JWT service
    @InjectModel(User.name) private userModel: Model<User>,
    @Inject(REQUEST) private request: Request
  ) { }

  // ========== REGISTRATION ==========
  async register({
    email,
    password,
    name,
    role,
    file
  }: {
    email: string;
    password: string;
    name: string;
    file?: Express.Multer.File,
    role: string,
  }) {
    // 1. Check if user exists
    const existingUser = await this.userModel.findOne({ email });

    if (existingUser) {
      throw new ConflictException('Email already in use');
    }

    // 2. Hash password (async recommended)
    const hashedPassword = await bcrypt.hash(password, 10);

    let image: string | null = null;
    if (file) {
      image = `/uploads/${file.filename}`
    }

    // 3. Create user
    const newUser = await this.userModel.create({
      email,
      password: hashedPassword,
      name,
      image,
      role: role,
    });

    // 4. Generate JWT token
    const payload = { sub: newUser._id, email: newUser.email, role: newUser.role };
    const accessToken = this.jwtService.sign(payload, { secret: "secret" });

    // // 5. Return user + token (without password)
    const { password: _, ...user } = newUser.toObject();
    return { user, accessToken };
  }

  // ========== LOGIN ==========
  async login(email: string, password: string) {
    // 1. Find user by email
    const user = await this.userModel.findOne({ email });
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if(user.isSuspended){
      throw new UnauthorizedException('User is suspended');
    }

    // 2. Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // 3. Generate JWT token
    const payload = { sub: user._id, email: user.email, role: user.role };
    const accessToken = this.jwtService.sign(payload, { secret: "secret" });

    // 4. Return user + token (without password)
    const { password: _, ...userData } = user.toObject();
    return { user: userData, accessToken };
  }

  async updateUserProfile(
    name: string,
    file?: Express.Multer.File,
  ): Promise<User> {
    const userId = this.request.user.sub;
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    user.name = name;

    if (file) {
      user.image = `/uploads/${file.filename}`;
    }

    await user.save();

    // Convert to object and remove password
    const userObject = user.toObject();
    return userObject;
  }

  async addNewToken(token: string){

    const userId = this.request.user.sub;
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // check of token alrady exists 
    const tokenExists = user.notification_tokens.find((t) => t === token);
    if (tokenExists) {
      throw new ConflictException('Token already exists');
    }
    user.notification_tokens.push( token );
    await user.save();
    
  }

  async suspendUnSuspendUser(isSuspended: boolean, userId: string) {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    user.isSuspended = isSuspended;
    await user.save();
    return true;

  }

  async getAllUsers() {
    return await this.userModel.find();
  }
}