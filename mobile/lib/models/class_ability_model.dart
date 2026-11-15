class ClassAbilityModel {
  final int id;
  final int rpgClassId;
  final String name;
  final String? description;

  const ClassAbilityModel({
    required this.id,
    required this.rpgClassId,
    required this.name,
    this.description,
  });

  factory ClassAbilityModel.fromJson(Map<String, dynamic> json) {
    return ClassAbilityModel(
      id: json['id'] as int,
      rpgClassId: json['rpg_class_id'] as int? ?? 0,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rpg_class_id': rpgClassId,
      'name': name,
      if (description != null) 'description': description,
    };
  }
}
