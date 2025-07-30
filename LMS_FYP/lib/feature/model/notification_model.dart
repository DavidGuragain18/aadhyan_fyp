// Define the NotificationStatus enum with 'sent' added
enum NotificationStatus { delivered, failed, read, sent }

// Extension to handle JSON serialization/deserialization
extension NotificationStatusExtension on NotificationStatus {
  String get toJsonString => toString().split('.').last;

  static NotificationStatus fromJsonString(String value) {
    return NotificationStatus.values.firstWhere(
      (status) => status.toJsonString == value,
      orElse: () => NotificationStatus.sent, // Default value if not found
    );
  }
}

// Model for recipient user objects
class NotificationRecipient {
  final String id;
  final String name;
  final String email;
  final String? image;
  final String role;
  final bool isSuspended;
  final List<String> notificationTokens;
  final List<String> enrollments;
  final DateTime? updatedAt;
  final int version;

  NotificationRecipient({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    required this.role,
    required this.isSuspended,
    required this.notificationTokens,
    required this.enrollments,
    this.updatedAt,
    required this.version,
  });

  factory NotificationRecipient.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationRecipient(
        id: json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        image: json['image']?.toString(),
        role: json['role']?.toString() ?? '',
        isSuspended: json['isSuspended'] ?? false,
        notificationTokens: List<String>.from(
          json['notification_tokens'] ?? [],
        ),
        enrollments: List<String>.from(json['enrollments'] ?? []),
        updatedAt:
            json['updatedAt'] != null && json['updatedAt'].toString().isNotEmpty
            ? DateTime.parse(json['updatedAt'])
            : null,
        version: json['__v'] ?? 0,
      );
    } catch (e) {
      print('Error parsing NotificationRecipient: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'image': image,
      'role': role,
      'isSuspended': isSuspended,
      'notification_tokens': notificationTokens,
      'enrollments': enrollments,
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }
}

// Model for individual user notification status
class UserNotificationStatus {
  final String userId;
  final NotificationStatus status;
  final String id;

  UserNotificationStatus({
    required this.userId,
    required this.status,
    required this.id,
  });

  factory UserNotificationStatus.fromJson(Map<String, dynamic> json) {
    try {
      return UserNotificationStatus(
        userId: json['userId']?.toString() ?? '',
        status: NotificationStatusExtension.fromJsonString(
          json['status']?.toString() ?? 'sent',
        ),
        id: json['_id']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing UserNotificationStatus: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'status': status.toJsonString, '_id': id};
  }

  @override
  String toString() {
    return 'UserNotificationStatus(userId: $userId, status: ${status.toJsonString}, id: $id)';
  }
}

class NotificationModel {
  final String id;
  final List<NotificationRecipient> recipients;
  final String title;
  final String body;
  final NotificationData? data;
  final String type;
  final NotificationStatus status;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final List<UserNotificationStatus> notificationStatus; // Added this field

  NotificationModel({
    required this.id,
    required this.recipients,
    required this.title,
    required this.body,
    this.data,
    required this.type,
    required this.status,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.notificationStatus,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationModel(
        id: json['_id']?.toString() ?? '',
        recipients:
            (json['recipients'] as List?)
                ?.map((recipient) => NotificationRecipient.fromJson(recipient))
                .toList() ??
            [],
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        data: json['data'] != null
            ? NotificationData.fromJson(json['data'])
            : null,
        type: json['type']?.toString() ?? '',
        status: NotificationStatusExtension.fromJsonString(
          json['status']?.toString() ?? 'sent',
        ),
        isRead: json['isRead'] ?? false,
        readAt: json['readAt'] != null && json['readAt'].toString().isNotEmpty
            ? DateTime.parse(json['readAt'])
            : null,
        createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          json['updatedAt'] ?? DateTime.now().toIso8601String(),
        ),
        version: json['__v'] ?? 0,
        notificationStatus:
            (json['notificationStatus'] as List?)
                ?.map((status) => UserNotificationStatus.fromJson(status))
                .toList() ??
            [],
      );
    } catch (e) {
      print('Error parsing NotificationModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'recipients': recipients.map((recipient) => recipient.toJson()).toList(),
      'title': title,
      'body': body,
      'data': data?.toJson(),
      'type': type,
      'status': status.toJsonString,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
      'notificationStatus': notificationStatus
          .map((status) => status.toJson())
          .toList(),
    };
  }

  // Helper method to check if notification is read by a specific user
  bool isReadByUser(String userId) {
    return notificationStatus.any(
      (status) =>
          status.userId == userId && status.status == NotificationStatus.read,
    );
  }

  // Helper method to get user-specific status
  NotificationStatus getStatusForUser(String userId) {
    final userStatus = notificationStatus.firstWhere(
      (status) => status.userId == userId,
      orElse: () => UserNotificationStatus(
        userId: userId,
        status: this.status, // Fall back to general status
        id: '',
      ),
    );
    return userStatus.status;
  }

  NotificationModel copyWith({
    String? id,
    List<NotificationRecipient>? recipients,
    String? title,
    String? body,
    NotificationData? data,
    String? type,
    NotificationStatus? status,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    List<UserNotificationStatus>? notificationStatus,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipients: recipients ?? this.recipients,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      type: type ?? this.type,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      notificationStatus: notificationStatus ?? this.notificationStatus,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, body: $body, type: $type, status: ${status.toJsonString}, isRead: $isRead, recipients: ${recipients.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class NotificationData {
  final String courseId;

  NotificationData({required this.courseId});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationData(courseId: json['courseId']?.toString() ?? '');
    } catch (e) {
      print('Error parsing NotificationData: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'courseId': courseId};
  }

  NotificationData copyWith({String? courseId}) {
    return NotificationData(courseId: courseId ?? this.courseId);
  }

  @override
  String toString() {
    return 'NotificationData(courseId: $courseId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationData && other.courseId == courseId;
  }

  @override
  int get hashCode => courseId.hashCode;
}
