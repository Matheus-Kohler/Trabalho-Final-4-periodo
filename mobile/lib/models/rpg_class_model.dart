import 'class_ability_model.dart';

class RPGClassModel {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final int hpBase;
  final double goldInitial;
  final List<ClassAbilityModel> abilities;

  const RPGClassModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.hpBase,
    required this.goldInitial,
    this.abilities = const [],
  });

  factory RPGClassModel.fromJson(Map<String, dynamic> json) {
    var rawAbilities = json['abilities'];
    List<ClassAbilityModel> abilitiesList = [];
    if (rawAbilities is List) {
      abilitiesList = rawAbilities
          .map((a) => ClassAbilityModel.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    return RPGClassModel(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String,
      description: json['description'] as String?,
      hpBase: json['hp_base'] as int? ?? 10,
      goldInitial: (json['gold_initial'] is num)
          ? (json['gold_initial'] as num).toDouble()
          : (double.tryParse(json['gold_initial']?.toString() ?? '0') ?? 0.0),
      abilities: abilitiesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      if (description != null) 'description': description,
      'hp_base': hpBase,
      'gold_initial': goldInitial,
      'abilities': abilities.map((a) => a.toJson()).toList(),
    };
  }
}
