import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionModel {
  final String? id; // Firestore document ID
  final String formId;
  final Map<String, dynamic> data; // Raw response data
  final Map<String, String>?
      questionLabels; // Question labels for each field ID
  final Map<String, String>? questionAnswers; // Question answers with labels
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
    this.questionLabels,
    this.questionAnswers,
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
      'questionLabels': questionLabels,
      'questionAnswers': questionAnswers,
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
      questionLabels: map['questionLabels'] != null
          ? Map<String, String>.from(map['questionLabels'])
          : null,
      questionAnswers: map['questionAnswers'] != null
          ? Map<String, String>.from(map['questionAnswers'])
          : null,
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
    Map<String, String>? questionLabels,
    Map<String, String>? questionAnswers,
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
      questionLabels: questionLabels ?? this.questionLabels,
      questionAnswers: questionAnswers ?? this.questionAnswers,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      submitterName: submitterName ?? this.submitterName,
      submitterEmail: submitterEmail ?? this.submitterEmail,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }

  // Helper method to get question label with null safety
  String getQuestionLabel(String fieldId) {
    if (questionLabels != null && questionLabels!.containsKey(fieldId)) {
      return questionLabels![fieldId]!;
    }
    // Fallback for old data without labels
    return 'Question $fieldId';
  }

  // Helper method to get question answer with null safety
  String getQuestionAnswer(String fieldId) {
    if (questionAnswers != null && questionAnswers!.containsKey(fieldId)) {
      return questionAnswers![fieldId]!;
    }
    // Fallback for old data
    final rawAnswer = data[fieldId];
    if (rawAnswer != null) {
      return rawAnswer.toString();
    }
    return '';
  }

  // Get all questions and answers in a structured format
  List<Map<String, String>> getStructuredData() {
    final List<Map<String, String>> structuredData = [];

    if (questionLabels != null && questionAnswers != null) {
      // New format with labels and answers
      questionLabels!.forEach((fieldId, label) {
        final answer = questionAnswers![fieldId] ?? '';
        structuredData.add({
          'label': label,
          'answer': answer,
        });
      });
    } else {
      // Fallback for old data - try to reconstruct from raw data
      data.forEach((fieldId, value) {
        if (fieldId != 'name' && fieldId != 'email') {
          // Skip metadata fields
          structuredData.add({
            'label': 'Question $fieldId',
            'answer': value?.toString() ?? '',
          });
        }
      });
    }

    return structuredData;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubmissionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
