import 'rpg_class_model.dart';

class CharacterModel {
  final int id;
  final int userId;
  final int? rpgClassId;
  final String name;
  final String race;
  final int level;
  final int hpCurrent;
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final double gold;
  final String? history;
  final String? description;
  final RPGClassModel? rpgClass;

  const CharacterModel({
    required this.id,
    required this.userId,
    this.rpgClassId,
    required this.name,
    required this.race,
    this.level = 1,
    this.hpCurrent = 10,
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.gold = 0.0,
    this.history,
    this.description,
    this.rpgClass,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      rpgClassId: json['rpg_class_id'] as int?,
      name: json['name'] as String,
      race: json['race'] as String? ?? 'Desconhecida',
      level: json['level'] as int? ?? 1,
      hpCurrent: json['hp_current'] as int? ?? 10,
      strength: json['strength'] as int? ?? 10,
      dexterity: json['dexterity'] as int? ?? 10,
      constitution: json['constitution'] as int? ?? 10,
      intelligence: json['intelligence'] as int? ?? 10,
      wisdom: json['wisdom'] as int? ?? 10,
      charisma: json['charisma'] as int? ?? 10,
      gold: (json['gold'] is num)
          ? (json['gold'] as num).toDouble()
          : (double.tryParse(json['gold']?.toString() ?? '0') ?? 0.0),
      history: json['history'] as String?,
      description: json['description'] as String?,
      rpgClass: json['rpg_class'] != null
          ? RPGClassModel.fromJson(json['rpg_class'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (rpgClassId != null) 'rpg_class_id': rpgClassId,
      'name': name,
      'race': race,
      'level': level,
      'hp_current': hpCurrent,
      'strength': strength,
      'dexterity': dexterity,
      'constitution': constitution,
      'intelligence': intelligence,
      'wisdom': wisdom,
      'charisma': charisma,
      'gold': gold,
      if (history != null) 'history': history,
      if (description != null) 'description': description,
    };
  }
}
