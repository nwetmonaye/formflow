class FormModel {
  final String? id;
  final String title;
  final String description;
  final List<FormField> fields;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool emailNotifications;
  final String? shareLink;
  final String status; // 'draft', 'active', 'closed'
  final String colorTheme; // 'blue', 'green', 'orange', 'red'
  final bool requiresApproval; // New field for approval toggle

  FormModel({
    this.id,
    required this.title,
    required this.description,
    required this.fields,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.emailNotifications = false,
    this.shareLink,
    this.status = 'draft',
    this.colorTheme = 'blue',
    this.requiresApproval = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'fields': fields.map((field) => field.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'emailNotifications': emailNotifications,
      'shareLink': shareLink,
      'status': status,
      'colorTheme': colorTheme,
      'requiresApproval': requiresApproval,
    };
  }

  factory FormModel.fromMap(Map<String, dynamic> map, String id) {
    return FormModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      fields: List<FormField>.from(
        map['fields']?.map((x) => FormField.fromMap(x)) ?? [],
      ),
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
      isActive: map['isActive'] ?? true,
      emailNotifications: map['emailNotifications'] ?? false,
      shareLink: map['shareLink'],
      status: map['status'] ?? 'draft',
      colorTheme: map['colorTheme'] ?? 'blue',
      requiresApproval: map['requiresApproval'] ?? false,
    );
  }

  FormModel copyWith({
    String? id,
    String? title,
    String? description,
    List<FormField>? fields,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? emailNotifications,
    String? shareLink,
    String? status,
    String? colorTheme,
    bool? requiresApproval,
  }) {
    return FormModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fields: fields ?? this.fields,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      shareLink: shareLink ?? this.shareLink,
      status: status ?? this.status,
      colorTheme: colorTheme ?? this.colorTheme,
      requiresApproval: requiresApproval ?? this.requiresApproval,
    );
  }
}

class FormField {
  final String id;
  final String label;
  final String
      type; // 'text', 'number', 'multiple_choice', 'checkbox', 'dropdown', 'date', 'file_upload'
  final bool required;
  final List<String>? options;
  final String? placeholder;
  final int? maxFileSize; // in MB, for file upload

  FormField({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.options,
    this.placeholder,
    this.maxFileSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'type': type,
      'required': required,
      'options': options,
      'placeholder': placeholder,
      'maxFileSize': maxFileSize,
    };
  }

  factory FormField.fromMap(Map<String, dynamic> map) {
    return FormField(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      type: map['type'] ?? 'text',
      required: map['required'] ?? false,
      options: List<String>.from(map['options'] ?? []),
      placeholder: map['placeholder'],
      maxFileSize: map['maxFileSize'],
    );
  }

  FormField copyWith({
    String? id,
    String? label,
    String? type,
    bool? required,
    List<String>? options,
    String? placeholder,
    int? maxFileSize,
  }) {
    return FormField(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      required: required ?? this.required,
      options: options ?? this.options,
      placeholder: placeholder ?? this.placeholder,
      maxFileSize: maxFileSize ?? this.maxFileSize,
    );
  }
}
