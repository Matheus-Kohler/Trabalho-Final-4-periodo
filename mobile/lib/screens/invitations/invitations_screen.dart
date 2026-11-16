import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/campaign_invitation_model.dart';
import '../../services/app_data_notifier.dart';
import '../../services/invitation_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  final _invitationService = InvitationService();

  bool _isLoading = true;
  String? _errorMessage;
  List<CampaignInvitationModel> _invitations = [];
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    AppDataNotifier.instance.addListener(_handleDataChanged);
    _loadInvitations();
  }

  void _handleDataChanged() {
    _loadInvitations();
  }

  @override
  void dispose() {
    AppDataNotifier.instance.removeListener(_handleDataChanged);
    super.dispose();
  }

  Future<void> _loadInvitations() async {
    final generation = ++_loadGeneration;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final invitations = await _invitationService.getPendingInvitations();
      if (mounted && generation == _loadGeneration) {
        setState(() {
          _invitations = invitations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && generation == _loadGeneration) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _respond(int id, bool accept) async {
    try {
      if (accept) {
        await _invitationService.acceptInvitation(id);
      } else {
        await _invitationService.rejectInvitation(id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept
                  ? 'Convite aceito! Personagem adicionado à campanha.'
                  : 'Convite recusado.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convites de Campanha'),
        actions: [
          IconButton(
            tooltip: 'Atualizar convites',
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvitations,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInvitations,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_errorMessage != null) {
      return ErrorView(message: _errorMessage!, onRetry: _loadInvitations);
    }

    if (_invitations.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const EmptyStateView(
              message: AppConstants.emptyInvitationsText,
              icon: Icons.mark_email_read_outlined,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _invitations.length,
      itemBuilder: (context, index) {
        final inv = _invitations[index];
        final campaignName =
            inv.campaign?.name ?? 'Campanha #${inv.campaignId}';
        final masterName = inv.campaign?.master?.name ?? 'Mestre';
        final charName =
            inv.character?.name ?? 'Personagem #${inv.characterId}';

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.secondary,
                    child: Icon(Icons.mail, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(campaignName, style: AppTextStyles.titleMedium),
                        Text(
                          'Mestre: $masterName',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Seu personagem convocado: $charName',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.error,
                    ),
                    label: Text(
                      'Recusar',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    onPressed: () => _respond(inv.id, false),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Aceitar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    onPressed: () => _respond(inv.id, true),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
