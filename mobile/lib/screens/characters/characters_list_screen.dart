import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/character_model.dart';
import '../../services/character_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

class CharactersListScreen extends StatefulWidget {
  const CharactersListScreen({super.key});

  @override
  State<CharactersListScreen> createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen> {
  final _characterService = CharacterService();

  bool _isLoading = true;
  String? _errorMessage;
  List<CharacterModel> _characters = [];

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final characters = await _characterService.getCharacters();
      if (mounted) {
        setState(() {
          _characters = characters;
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

  Future<void> _deleteCharacter(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Personagem'),
        content: const Text(
          'Tem certeza que deseja enviar este herói para o descanso eterno?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _characterService.deleteCharacter(id);
        _loadCharacters();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingIndicator();

    if (_errorMessage != null) {
      return ErrorView(message: _errorMessage!, onRetry: _loadCharacters);
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadCharacters,
        child: _characters.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: EmptyStateView(
                      message: AppConstants.emptyCharactersText,
                      icon: Icons.shield_outlined,
                      actionLabel: 'Criar Meu Primeiro Herói',
                      onAction: () async {
                        await context.pushNamed(AppRoutes.characterForm);
                        _loadCharacters();
                      },
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _characters.length,
                itemBuilder: (context, index) {
                  final char = _characters[index];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                char.name.isNotEmpty ? char.name[0] : '?',
                                style: AppTextStyles.titleMedium,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    char.name,
                                    style: AppTextStyles.titleMedium,
                                  ),
                                  Text(
                                    '${char.race} • ${char.rpgClass?.name ?? "Sem classe"} • Nível ${char.level}',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => _deleteCharacter(char.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(color: AppColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAttr(
                              'HP',
                              char.hpCurrent.toString(),
                              AppColors.error,
                            ),
                            _buildAttr(
                              'FOR',
                              char.strength.toString(),
                              AppColors.secondary,
                            ),
                            _buildAttr(
                              'DES',
                              char.dexterity.toString(),
                              AppColors.secondary,
                            ),
                            _buildAttr(
                              'CON',
                              char.constitution.toString(),
                              AppColors.secondary,
                            ),
                            _buildAttr(
                              'INT',
                              char.intelligence.toString(),
                              AppColors.secondary,
                            ),
                            _buildAttr(
                              'OURO',
                              AppFormatters.gold(char.gold),
                              AppColors.warning,
                            ),
                          ],
                        ),
                        if (char.description != null &&
                            char.description!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            char.description!,
                            style: AppTextStyles.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Novo Herói'),
        onPressed: () async {
          await context.pushNamed(AppRoutes.characterForm);
          _loadCharacters();
        },
      ),
    );
  }

  Widget _buildAttr(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
