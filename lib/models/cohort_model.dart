class CohortModel {
  final String? id;
  final String name;
  final List<CohortRecipient> recipients;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CohortModel({
    this.id,
    required this.name,
    required this.recipients,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'recipients': recipients.map((recipient) => recipient.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CohortModel.fromMap(Map<String, dynamic> map, String id) {
    return CohortModel(
      id: id,
      name: map['name'] ?? '',
      recipients: List<CohortRecipient>.from(
        map['recipients']?.map((x) => CohortRecipient.fromMap(x)) ?? [],
      ),
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  CohortModel copyWith({
    String? id,
    String? name,
    List<CohortRecipient>? recipients,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CohortModel(
      id: id ?? this.id,
      name: name ?? this.name,
      recipients: recipients ?? this.recipients,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CohortRecipient {
  final String name;
  final String email;

  CohortRecipient({
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }

  factory CohortRecipient.fromMap(Map<String, dynamic> map) {
    return CohortRecipient(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  CohortRecipient copyWith({
    String? name,
    String? email,
  }) {
    return CohortRecipient(
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
