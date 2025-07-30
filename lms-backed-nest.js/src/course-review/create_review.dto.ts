import { ApiProperty } from "@nestjs/swagger";
import { IsMongoId, IsNotEmpty, IsInt, Min, Max, IsString } from "class-validator";

export class CreateReviewDto {
  @ApiProperty({ description: 'The ID of the course being reviewed', example: '687dfbe86be859bf15944437', required: true, type: String })
  @IsMongoId()
  @IsNotEmpty()
  readonly course: string;

  // @ApiProperty({ description: 'The ID of the user submitting the review', example: '687dfbe86be859bf15944440', required: true, type: String })
  // @IsMongoId()
  // @IsNotEmpty()
  // readonly user: string;

  @ApiProperty({ description: 'The rating for the course (1 to 5)', example: 4, required: true, type: Number })
  @IsInt()
  @Min(1)
  @Max(5)
  readonly rating: number;
  
  @ApiProperty({ description: 'The review comment', example: 'Great course, very informative!', required: true, type: String })
  @IsString()
  @IsNotEmpty()
  readonly comment: string;
}