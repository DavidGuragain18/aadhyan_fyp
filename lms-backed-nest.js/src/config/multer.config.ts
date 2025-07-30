import { diskStorage } from 'multer';
import { extname } from 'path';

export const multerOptions = {
  storage: diskStorage({
    destination: './uploads/course-covers',
    filename: (req, file, callback) => {
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
      const ext = extname(file.originalname);
      const filename = `${uniqueSuffix}${ext}`;
      callback(null, filename);
    },
  }),
  limits: {
    fileSize: 1024 * 1024 * 5, // 5 MB
  },
  fileFilter: (req, file, callback) => {
    // if (!file.mimetype.match(/\/(jpg|jpeg|png|gif|webp)$/)) {
    //   return callback(new Error('Only image files are allowed!'), false);
    // }
    callback(null, true);
  },
};