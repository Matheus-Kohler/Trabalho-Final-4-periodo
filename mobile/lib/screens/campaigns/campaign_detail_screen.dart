import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/campaign_model.dart';
import '../../models/character_model.dart';
import '../../models/rpg_class_model.dart';
import '../../services/campaign_service.dart';
import '../../services/character_service.dart';
import '../../services/rpg_class_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

class CampaignDetailScreen extends StatefulWidget {
  final int campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  final _campaignService = CampaignService();
  final _characterService = CharacterService();
  final _classService = RPGClassService();

  bool _isLoading = true;
  String? _errorMessage;
  CampaignModel? _campaign;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final campaign = await _campaignService.getCampaign(widget.campaignId);
      if (mounted) {
        setState(() {
          _campaign = campaign;
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

  Future<void> _showAddCharacterDialog() async {
    List<CharacterModel> allCharacters = [];
    try {
      allCharacters = await _characterService.getCharacters();
    } catch (_) {}

    if (!mounted) return;

    final existingIds = _campaign?.characters.map((c) => c.id).toSet() ?? {};
    final availableCharacters = allCharacters
        .where((c) => !existingIds.contains(c.id))
        .toList();

    if (availableCharacters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há personagens disponíveis para vincular.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vincular Personagem à Campanha'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableCharacters.length,
            itemBuilder: (ctx, i) {
              final char = availableCharacters[i];
              return ListTile(
                title: Text(char.name),
                subtitle: Text('${char.race} • Nível ${char.level}'),
                trailing: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.secondary,
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    await _campaignService.attachCharacter(
                      widget.campaignId,
                      char.id,
                    );
                    _loadDetails();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddClassDialog() async {
    List<RPGClassModel> allClasses = [];
    try {
      allClasses = await _classService.getClasses();
    } catch (_) {}

    if (!mounted) return;

    final existingIds = _campaign?.classes.map((c) => c.id).toSet() ?? {};
    final availableClasses = allClasses
        .where((c) => !existingIds.contains(c.id))
        .toList();

    if (availableClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Todas as classes já estão disponibilizadas nesta campanha.',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disponibilizar Classe na Campanha'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableClasses.length,
            itemBuilder: (ctx, i) {
              final rpgClass = availableClasses[i];
              return ListTile(
                title: Text(rpgClass.name),
                subtitle: Text(
                  'HP Base: ${rpgClass.hpBase} • ${AppFormatters.gold(rpgClass.goldInitial)}',
                ),
                trailing: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.secondary,
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    await _campaignService.attachClass(
                      widget.campaignId,
                      rpgClass.id,
                    );
                    _loadDetails();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Campanha')),
        body: const LoadingIndicator(),
      );
    }

    if (_errorMessage != null || _campaign == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Campanha')),
        body: ErrorView(
          message: _errorMessage ?? 'Campanha não encontrada.',
          onRetry: _loadDetails,
        ),
      );
    }

    final campaign = _campaign!;

    return Scaffold(
      appBar: AppBar(title: Text(campaign.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Principal da Campanha
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status: ${campaign.status.toUpperCase()}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: campaign.status == 'ativa'
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (campaign.master != null)
                        Text(
                          'Mestre: ${campaign.master!.name}',
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    campaign.description ?? 'Sem descrição detalhada.',
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Seção de Personagens
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Personagens na Aventura',
                  style: AppTextStyles.titleMedium,
                ),
                IconButton(
                  tooltip: 'Adicionar Personagem',
                  icon: const Icon(
                    Icons.person_add_alt,
                    color: AppColors.secondary,
                  ),
                  onPressed: _showAddCharacterDialog,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (campaign.characters.isEmpty)
              const EmptyStateView(
                message: 'Nenhum personagem vinculado a esta mesa.',
                icon: Icons.person_off_outlined,
              )
            else
              ...campaign.characters.map(
                (char) => AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.shield, color: AppColors.textPrimary),
                    ),
                    title: Text(char.name, style: AppTextStyles.titleSmall),
                    subtitle: Text(
                      '${char.race} • ${char.rpgClass?.name ?? "Sem classe"} • Nível ${char.level}\nHP: ${char.hpCurrent} • ${AppFormatters.gold(char.gold)}',
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.error,
                      ),
                      tooltip: 'Remover da campanha',
                      onPressed: () async {
                        await _campaignService.detachCharacter(
                          campaign.id,
                          char.id,
                        );
                        _loadDetails();
                      },
                    ),
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.lg),

            // Seção de Classes Liberadas pelo Mestre
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Classes Disponibilizadas',
                  style: AppTextStyles.titleMedium,
                ),
                IconButton(
                  tooltip: 'Disponibilizar Classe',
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppColors.secondary,
                  ),
                  onPressed: _showAddClassDialog,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (campaign.classes.isEmpty)
              const EmptyStateView(
                message:
                    'Nenhuma classe foi disponibilizada pelo mestre ainda.',
                icon: Icons.lock_outline,
              )
            else
              ...campaign.classes.map(
                (rpgClass) => AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.secondary,
                      child: Icon(
                        Icons.auto_fix_high,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    title: Text(rpgClass.name, style: AppTextStyles.titleSmall),
                    subtitle: Text(
                      'HP Base: ${rpgClass.hpBase} • Ouro Inicial: ${AppFormatters.gold(rpgClass.goldInitial)}\n${rpgClass.abilities.length} habilidades especiais',
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.error,
                      ),
                      tooltip: 'Revogar classe da campanha',
                      onPressed: () async {
                        await _campaignService.detachClass(
                          campaign.id,
                          rpgClass.id,
                        );
                        _loadDetails();
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
