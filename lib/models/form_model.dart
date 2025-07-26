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
    );
  }
}

class FormField {
  final String id;
  final String label;
  final String type;
  final bool required;
  final List<String>? options;
  final String? placeholder;

  FormField({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.options,
    this.placeholder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'type': type,
      'required': required,
      'options': options,
      'placeholder': placeholder,
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
    );
  }
}
