import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/rpg_class_model.dart';
import '../../services/rpg_class_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

class ClassesListScreen extends StatefulWidget {
  const ClassesListScreen({super.key});

  @override
  State<ClassesListScreen> createState() => _ClassesListScreenState();
}

class _ClassesListScreenState extends State<ClassesListScreen> {
  final _classService = RPGClassService();

  bool _isLoading = true;
  String? _errorMessage;
  List<RPGClassModel> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final classes = await _classService.getClasses();
      if (mounted) {
        setState(() {
          _classes = classes;
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

  Future<void> _deleteClass(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Classe'),
        content: const Text(
          'Tem certeza que deseja excluir esta classe personalizada?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Excluir',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _classService.deleteClass(id);
        _loadClasses();
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
      return ErrorView(message: _errorMessage!, onRetry: _loadClasses);
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadClasses,
        child: _classes.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: EmptyStateView(
                      message: AppConstants.emptyClassesText,
                      icon: Icons.auto_fix_high_outlined,
                      actionLabel: 'Criar Classe Personalizada',
                      onAction: () async {
                        await context.pushNamed(AppRoutes.classForm);
                        _loadClasses();
                      },
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _classes.length,
                itemBuilder: (context, index) {
                  final rpgClass = _classes[index];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.secondary,
                              child: Icon(
                                Icons.auto_fix_high,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rpgClass.name,
                                    style: AppTextStyles.titleMedium,
                                  ),
                                  Text(
                                    'HP Base: ${rpgClass.hpBase} • Ouro Inicial: ${AppFormatters.gold(rpgClass.goldInitial)}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => _deleteClass(rpgClass.id),
                            ),
                          ],
                        ),
                        if (rpgClass.description != null &&
                            rpgClass.description!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            rpgClass.description!,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                        if (rpgClass.abilities.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          const Divider(color: AppColors.border),
                          const Text(
                            'Habilidades Especiais:',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: rpgClass.abilities.map((ability) {
                              return Chip(
                                backgroundColor: AppColors.surfaceVariant,
                                label: Text(
                                  ability.name,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
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
        label: const Text('Nova Classe'),
        onPressed: () async {
          await context.pushNamed(AppRoutes.classForm);
          _loadClasses();
        },
      ),
    );
  }
}
