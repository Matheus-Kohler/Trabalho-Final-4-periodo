import '../models/character_model.dart';
import 'api_client.dart';

class CharacterService {
  final ApiClient _client = ApiClient();

  Future<List<CharacterModel>> getCharacters() async {
    final response = await _client.get('/characters');
    final data = response['data'] as List? ?? [];
    return data
        .map((item) => CharacterModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CharacterModel> getCharacter(int id) async {
    final response = await _client.get('/characters/$id');
    final data = response['data'] as Map<String, dynamic>;
    return CharacterModel.fromJson(data);
  }

  Future<CharacterModel> createCharacter(
    Map<String, dynamic> characterData,
  ) async {
    final response = await _client.post('/characters', characterData);
    final data = response['data'] as Map<String, dynamic>;
    return CharacterModel.fromJson(data);
  }

  Future<CharacterModel> updateCharacter(
    int id,
    Map<String, dynamic> characterData,
  ) async {
    final response = await _client.put('/characters/$id', characterData);
    final data = response['data'] as Map<String, dynamic>;
    return CharacterModel.fromJson(data);
  }

  Future<void> deleteCharacter(int id) async {
    await _client.delete('/characters/$id');
  }
}
