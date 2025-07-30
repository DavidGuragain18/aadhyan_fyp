import { Injectable } from '@nestjs/common';
import { FirebaseService } from './firebase.service';

@Injectable()
export class FirebaseNotification {
  constructor(private readonly firebaseService: FirebaseService) {}

  async sendPushNotification(
    deviceToken: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ) {
    const message = {
      notification: {
        title,
        body,
      },
      data,
      token: deviceToken,
    };

    try {
      const response = await this.firebaseService
        .getMessaging()
        .send(message);
      console.log('Successfully sent message:', response);
      return response;
    } catch (error) {
      console.error('Error sending message:', error);
      throw error;
    }
  }

//   async sendToMultipleDevices(
//     deviceTokens: string[],
//     title: string,
//     body: string,
//     data?: Record<string, string>,
//   ) {
//     const message = {
//       notification: {
//         title,
//         body,
//       },
//       data,
//       tokens: deviceTokens,
//     };

//     try {
//       const response = await this.firebaseService
//         .getMessaging()
//         .sendMulticast(message);
//       console.log('Successfully sent multicast message:', response);
//       return response;
//     } catch (error) {
//       console.error('Error sending multicast message:', error);
//       throw error;
//     }
//   }
}