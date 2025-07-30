import { HttpException, HttpStatus, Injectable, Scope, UnauthorizedException, NestMiddleware } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { NextFunction, Request, Response } from "express";


declare module "express"{
    interface Request{
        user:any;
    }
}
@Injectable({ scope: Scope.DEFAULT })
export class AuthMiddleware  implements  NestMiddleware{

    constructor(private readonly jwtService: JwtService) { }
    async use(req: Request, res: Response, next: NextFunction) {
        const tokens = req.headers.authorization?.split(' ');
        if (!tokens || !tokens.length) {
            throw new UnauthorizedException("Token not provided");
        }

        const token = tokens[1];

        try {
            // Validate token and get user payload
            const payload = await this.validateToken(token);
            // Attach user data to request for downstream use
            req.user = payload;
            next(); // Proceed to next middleware or route handler
        } catch (error) {
            console.log(error);
            
            // Error is already formatted by AuthService
            return res.status(error.status || HttpStatus.UNAUTHORIZED).json(error.getResponse());
        }


    }

    async validateToken(token: string): Promise<any> {
        try {
            return await this.jwtService.verifyAsync(token,{secret: "secret"});
        } catch (error) {
            console.log(error);
            
            if (error.name === 'TokenExpiredError') {
                throw new UnauthorizedException({
                    error: 'TokenExpired',
                    message: 'Access token has expired',
                });
            }

            throw new UnauthorizedException({
                error: 'InvalidToken',
                message: 'Invalid authentication token',
            });
        }
    }
}