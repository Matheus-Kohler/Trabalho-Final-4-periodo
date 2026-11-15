import 'character_model.dart';
import 'rpg_class_model.dart';
import 'user_model.dart';

class CampaignModel {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final String status;
  final UserModel? master;
  final List<RPGClassModel> classes;
  final List<CharacterModel> characters;
  final DateTime? createdAt;

  const CampaignModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.status = 'ativa',
    this.master,
    this.classes = const [],
    this.characters = const [],
    this.createdAt,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    var rawClasses = json['classes'];
    List<RPGClassModel> classesList = [];
    if (rawClasses is List) {
      classesList = rawClasses
          .map((c) => RPGClassModel.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    var rawCharacters = json['characters'];
    List<CharacterModel> charactersList = [];
    if (rawCharacters is List) {
      charactersList = rawCharacters
          .map((char) => CharacterModel.fromJson(char as Map<String, dynamic>))
          .toList();
    }

    return CampaignModel(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'ativa',
      master: json['master'] != null
          ? UserModel.fromJson(json['master'] as Map<String, dynamic>)
          : null,
      classes: classesList,
      characters: charactersList,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      if (description != null) 'description': description,
      'status': status,
      'classes': classes.map((c) => c.toJson()).toList(),
      'characters': characters.map((c) => c.toJson()).toList(),
    };
  }
}
