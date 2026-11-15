import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/campaign_model.dart';
import '../../services/campaign_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

class CampaignsListScreen extends StatefulWidget {
  const CampaignsListScreen({super.key});

  @override
  State<CampaignsListScreen> createState() => _CampaignsListScreenState();
}

class _CampaignsListScreenState extends State<CampaignsListScreen>
    with SingleTickerProviderStateMixin {
  final _campaignService = CampaignService();
  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;
  List<CampaignModel> _masterCampaigns = [];
  List<CampaignModel> _playerCampaigns = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCampaigns();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCampaigns() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final master = await _campaignService.getMasterCampaigns();
      final player = await _campaignService.getParticipatingCampaigns();

      if (mounted) {
        setState(() {
          _masterCampaigns = master;
          _playerCampaigns = player;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildCampaignItem(CampaignModel campaign, {required bool isMaster}) {
    Color statusColor;
    switch (campaign.status.toLowerCase()) {
      case 'ativa':
        statusColor = AppColors.success;
        break;
      case 'pausada':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.textMuted;
    }

    return AppCard(
      onTap: () async {
        await context.pushNamed(
          AppRoutes.campaignDetail,
          pathParameters: {'id': campaign.id.toString()},
        );
        _loadCampaigns();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  campaign.name,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  campaign.status.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (campaign.description != null &&
              campaign.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              campaign.description!,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.border),
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${campaign.characters.length} Heróis',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(
                Icons.shield_outlined,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${campaign.classes.length} Classes Liberadas',
                style: AppTextStyles.bodySmall,
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.secondary,
            labelColor: AppColors.secondary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Como Mestre (Gestão)'),
              Tab(text: 'Como Jogador (Leitura)'),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : _errorMessage != null
                ? ErrorView(message: _errorMessage!, onRetry: _loadCampaigns)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Mestre
                      RefreshIndicator(
                        onRefresh: _loadCampaigns,
                        child: _masterCampaigns.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.6,
                                    child: EmptyStateView(
                                      message: AppConstants.emptyCampaignsText,
                                      actionLabel: 'Criar Minha Primeira Campanha',
                                      onAction: () async {
                                        await context.pushNamed(
                                          AppRoutes.campaignForm,
                                        );
                                        _loadCampaigns();
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: _masterCampaigns.length,
                                itemBuilder: (context, index) {
                                  return _buildCampaignItem(
                                    _masterCampaigns[index],
                                    isMaster: true,
                                  );
                                },
                              ),
                      ),
                      // Tab 2: Jogador
                      RefreshIndicator(
                        onRefresh: _loadCampaigns,
                        child: _playerCampaigns.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.6,
                                    child: const EmptyStateView(
                                      message: AppConstants.emptyPlayerCampaignsText,
                                      icon: Icons.group_off_outlined,
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: _playerCampaigns.length,
                                itemBuilder: (context, index) {
                                  return _buildCampaignItem(
                                    _playerCampaigns[index],
                                    isMaster: false,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nova Campanha'),
        onPressed: () async {
          await context.pushNamed(AppRoutes.campaignForm);
          _loadCampaigns();
        },
      ),
    );
  }
}
