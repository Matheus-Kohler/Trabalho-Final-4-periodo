import '../models/campaign_model.dart';
import 'api_client.dart';

class CampaignService {
  final ApiClient _client = ApiClient();

  /// Campanhas onde o usuário logado é o mestre.
  Future<List<CampaignModel>> getMasterCampaigns() async {
    final response = await _client.get('/campaigns');
    final data = response['data'] as List? ?? [];
    return data
        .map((item) => CampaignModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Campanhas em que o usuário logado participa como jogador.
  Future<List<CampaignModel>> getParticipatingCampaigns() async {
    final response = await _client.get('/campaigns/participating');
    final data = response['data'] as List? ?? [];
    return data
        .map((item) => CampaignModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CampaignModel> getCampaign(int id) async {
    final response = await _client.get('/campaigns/$id');
    final data = response['data'] as Map<String, dynamic>;
    return CampaignModel.fromJson(data);
  }

  Future<CampaignModel> createCampaign({
    required String name,
    String? description,
    String status = 'ativa',
  }) async {
    final response = await _client.post('/campaigns', {
      'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
      'status': status,
    });
    final data = response['data'] as Map<String, dynamic>;
    return CampaignModel.fromJson(data);
  }

  Future<CampaignModel> updateCampaign(
    int id, {
    required String name,
    String? description,
    required String status,
  }) async {
    final response = await _client.put('/campaigns/$id', {
      'name': name,
      'description': ?description,
      'status': status,
    });
    final data = response['data'] as Map<String, dynamic>;
    return CampaignModel.fromJson(data);
  }

  Future<void> deleteCampaign(int id) async {
    await _client.delete('/campaigns/$id');
  }

  Future<CampaignModel> attachCharacter(int campaignId, int characterId) async {
    final response = await _client.post('/campaigns/$campaignId/characters', {
      'character_id': characterId,
    });
    final data = response['data'] as Map<String, dynamic>;
    return CampaignModel.fromJson(data);
  }

  Future<CampaignModel> detachCharacter(int campaignId, int characterId) async {
    final response = await _client.delete(
      '/campaigns/$campaignId/characters/$characterId',
    );
    final data = response['data'] as Map<String, dynamic>;
    return CampaignModel.fromJson(data);
  }

  Future<CampaignModel> attachClass(int campaignId, int classId) async {
    final response = await _client.post('/campaigns/$campaignId/classes', {
      'rpg_class_id': classId,
    });
    final data = response['data'] as Map<String, dynamic>;
    return CampaignModel.fromJson(data);
  }

  Future<CampaignModel> detachClass(int campaignId, int classId) async {
    final response = await _client.delete(
      '/campaigns/$campaignId/classes/$classId',
    );
    final data = response['data'] as Map<String, dynamic>;
    return CampaignModel.fromJson(data);
  }
}
