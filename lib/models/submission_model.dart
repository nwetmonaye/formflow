import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionModel {
  final String? id; // Firestore document ID
  final String formId;
  final Map<String, dynamic> data;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final String submitterName;
  final String submitterEmail;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  SubmissionModel({
    this.id,
    required this.formId,
    required this.data,
    required this.status,
    required this.createdAt,
    required this.submitterName,
    required this.submitterEmail,
    this.reviewedAt,
    this.reviewedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'formId': formId,
      'data': data,
      'status': status,
      'createdAt': createdAt,
      'submitterName': submitterName,
      'submitterEmail': submitterEmail,
      'reviewedAt': reviewedAt,
      'reviewedBy': reviewedBy,
    };
  }

  factory SubmissionModel.fromMap(Map<String, dynamic> map, String id) {
    return SubmissionModel(
      id: id,
      formId: map['formId'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      submitterName: map['submitterName'] ?? 'Anonymous',
      submitterEmail: map['submitterEmail'] ?? '',
      reviewedAt: map['reviewedAt']?.toDate(),
      reviewedBy: map['reviewedBy'],
    );
  }

  SubmissionModel copyWith({
    String? id,
    String? formId,
    Map<String, dynamic>? data,
    String? status,
    DateTime? createdAt,
    String? submitterName,
    String? submitterEmail,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      formId: formId ?? this.formId,
      data: data ?? this.data,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      submitterName: submitterName ?? this.submitterName,
      submitterEmail: submitterEmail ?? this.submitterEmail,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }
}
