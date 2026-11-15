import '../models/campaign_invitation_model.dart';
import '../models/character_model.dart';
import 'api_client.dart';

class InvitationService {
  final ApiClient _client = ApiClient();

  /// Busca personagens de um jogador por e-mail para convidar para uma campanha.
  Future<List<CharacterModel>> getAvailableCharacters(
    int campaignId, {
    String? email,
  }) async {
    final query = (email != null && email.trim().isNotEmpty)
        ? '?email=${Uri.encodeComponent(email.trim())}'
        : '';
    final response = await _client.get(
      '/campaigns/$campaignId/invitations/available-characters$query',
    );
    final data = response['data'] as List? ?? [];
    return data
        .map((item) => CharacterModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// O mestre envia convite para um personagem entrar na campanha.
  Future<CampaignInvitationModel> sendInvitation(
    int campaignId,
    int characterId,
  ) async {
    final response = await _client.post(
      '/campaigns/$campaignId/invitations',
      {'character_id': characterId},
    );
    final data = response['data'] as Map<String, dynamic>;
    return CampaignInvitationModel.fromJson(data);
  }

  /// Busca os convites pendentes recebidos pelo usuário autenticado.
  Future<List<CampaignInvitationModel>> getPendingInvitations() async {
    final response = await _client.get('/invitations/pending');
    final data = response['data'] as List? ?? [];
    return data
        .map((item) => CampaignInvitationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// O jogador aceita o convite para a campanha.
  Future<void> acceptInvitation(int invitationId) async {
    await _client.post('/invitations/$invitationId/accept', {});
  }

  /// O jogador recusa o convite para a campanha.
  Future<void> rejectInvitation(int invitationId) async {
    await _client.post('/invitations/$invitationId/reject', {});
  }
}
