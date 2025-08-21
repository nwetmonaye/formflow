import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? id;
  final String
      type; // 'form_submission', 'form_approved', 'form_rejected', etc.
  final String title;
  final String message;
  final String? formId;
  final String? submissionId;
  final String? submitterName;
  final String? submitterEmail;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    this.id,
    required this.type,
    required this.title,
    required this.message,
    this.formId,
    this.submissionId,
    this.submitterName,
    this.submitterEmail,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'message': message,
      'formId': formId,
      'submissionId': submissionId,
      'submitterName': submitterName,
      'submitterEmail': submitterEmail,
      'createdAt': createdAt,
      'isRead': isRead,
      'actionUrl': actionUrl,
      'metadata': metadata,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      formId: map['formId'],
      submissionId: map['submissionId'],
      submitterName: map['submitterName'],
      submitterEmail: map['submitterEmail'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      actionUrl: map['actionUrl'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    String? formId,
    String? submissionId,
    String? submitterName,
    String? submitterEmail,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      formId: formId ?? this.formId,
      submissionId: submissionId ?? this.submissionId,
      submitterName: submitterName ?? this.submitterName,
      submitterEmail: submitterEmail ?? this.submitterEmail,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  // Factory method for form submission notifications
  factory NotificationModel.formSubmission({
    required String formId,
    required String submissionId,
    required String submitterName,
    required String submitterEmail,
    required String formTitle,
  }) {
    return NotificationModel(
      type: 'form_submission',
      title: 'New Form Submission',
      message: '$submitterName submitted a response to $formTitle',
      formId: formId,
      submissionId: submissionId,
      submitterName: submitterName,
      submitterEmail: submitterEmail,
      createdAt: DateTime.now(),
      isRead: false,
    );
  }

  // Factory method for form approval notifications
  factory NotificationModel.formApproved({
    required String formId,
    required String formTitle,
  }) {
    return NotificationModel(
      type: 'form_approved',
      title: 'Form Approved',
      message: 'Your form "$formTitle" has been approved',
      formId: formId,
      createdAt: DateTime.now(),
      isRead: false,
    );
  }

  // Factory method for form rejection notifications
  factory NotificationModel.formRejected({
    required String formId,
    required String formTitle,
    String? reason,
  }) {
    return NotificationModel(
      type: 'form_rejected',
      title: 'Form Rejected',
      message: reason ?? 'Your form "$formTitle" has been rejected',
      formId: formId,
      createdAt: DateTime.now(),
      isRead: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
