import 'campaign_model.dart';
import 'character_model.dart';

class CampaignInvitationModel {
  final int id;
  final int campaignId;
  final int characterId;
  final String status;
  final CampaignModel? campaign;
  final CharacterModel? character;
  final DateTime? createdAt;

  const CampaignInvitationModel({
    required this.id,
    required this.campaignId,
    required this.characterId,
    this.status = 'pendente',
    this.campaign,
    this.character,
    this.createdAt,
  });

  factory CampaignInvitationModel.fromJson(Map<String, dynamic> json) {
    return CampaignInvitationModel(
      id: json['id'] as int,
      campaignId: json['campaign_id'] as int? ?? 0,
      characterId: json['character_id'] as int? ?? 0,
      status: json['status'] as String? ?? 'pendente',
      campaign: json['campaign'] != null && json['campaign'] is Map<String, dynamic>
          ? CampaignModel.fromJson(json['campaign'] as Map<String, dynamic>)
          : null,
      character: json['character'] != null && json['character'] is Map<String, dynamic>
          ? CharacterModel.fromJson(json['character'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'character_id': characterId,
      'status': status,
    };
  }
}
