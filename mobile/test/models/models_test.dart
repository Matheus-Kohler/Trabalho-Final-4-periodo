import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_manager/models/campaign_model.dart';
import 'package:rpg_manager/models/character_model.dart';
import 'package:rpg_manager/models/rpg_class_model.dart';

void main() {
  test('parses character data returned by the API', () {
    final character = CharacterModel.fromJson({
      'id': 7,
      'user_id': 3,
      'rpg_class_id': 2,
      'name': 'Thorin',
      'race': 'Anão',
      'level': 4,
      'hp_current': 28,
      'gold': '125.50',
    });

    expect(character.id, 7);
    expect(character.rpgClassId, 2);
    expect(character.gold, 125.5);
    expect(character.toJson()['name'], 'Thorin');
  });

  test('parses class abilities and decimal values from the API', () {
    final rpgClass = RPGClassModel.fromJson({
      'id': 2,
      'user_id': 3,
      'name': 'Guerreiro',
      'hp_base': 12,
      'gold_initial': '50.00',
      'abilities': [
        {'id': 9, 'rpg_class_id': 2, 'name': 'Bloqueio'},
      ],
    });

    expect(rpgClass.goldInitial, 50);
    expect(rpgClass.abilities.single.name, 'Bloqueio');
    expect(rpgClass.toJson()['abilities'], hasLength(1));
  });

  test('parses campaign status and relationships from the API', () {
    final campaign = CampaignModel.fromJson({
      'id': 5,
      'user_id': 3,
      'name': 'A Mina Perdida',
      'status': 'pausada',
      'characters': [
        {'id': 7, 'user_id': 3, 'name': 'Thorin', 'race': 'Anão'},
      ],
      'classes': [
        {
          'id': 2,
          'user_id': 3,
          'name': 'Guerreiro',
          'hp_base': 12,
          'gold_initial': 50,
        },
      ],
    });

    expect(campaign.status, 'pausada');
    expect(campaign.characters.single.name, 'Thorin');
    expect(campaign.classes.single.name, 'Guerreiro');
  });
}
