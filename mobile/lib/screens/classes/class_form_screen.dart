import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../models/class_ability_model.dart';
import '../../services/rpg_class_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

class ClassFormScreen extends StatefulWidget {
  final int? classId;

  const ClassFormScreen({super.key, this.classId});

  @override
  State<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hpBaseController = TextEditingController(text: '10');
  final _goldInitialController = TextEditingController(text: '100.00');
  final _abilityNameController = TextEditingController();
  final _abilityDescController = TextEditingController();

  final _classService = RPGClassService();
  bool _isLoading = false;
  bool _isLoadingInitialData = false;
  String? _errorMessage;
  String? _initialDataError;
  List<ClassAbilityModel> _abilities = [];

  bool get _isEditing => widget.classId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadClass();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hpBaseController.dispose();
    _goldInitialController.dispose();
    _abilityNameController.dispose();
    _abilityDescController.dispose();
    super.dispose();
  }

  Future<void> _loadClass() async {
    setState(() {
      _isLoadingInitialData = true;
      _initialDataError = null;
    });
    try {
      final rpgClass = await _classService.getClass(widget.classId!);
      if (mounted) {
        setState(() {
          _nameController.text = rpgClass.name;
          _descriptionController.text = rpgClass.description ?? '';
          _hpBaseController.text = rpgClass.hpBase.toString();
          _goldInitialController.text = rpgClass.goldInitial.toStringAsFixed(2);
          _abilities = rpgClass.abilities;
          _isLoadingInitialData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialDataError = e.toString();
          _isLoadingInitialData = false;
        });
      }
    }
  }

  Future<void> _removeAbility(ClassAbilityModel ability) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover habilidade'),
        content: Text('Deseja remover "${ability.name}" desta classe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Remover',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _classService.removeAbility(widget.classId!, ability.id);
      if (mounted) {
        setState(() {
          _abilities.removeWhere((item) => item.id == ability.id);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newAbility = _abilityNameController.text.trim().isEmpty
          ? null
          : {
              'name': _abilityNameController.text.trim(),
              if (_abilityDescController.text.trim().isNotEmpty)
                'description': _abilityDescController.text.trim(),
            };

      if (_isEditing) {
        await _classService.updateClass(
          widget.classId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          hpBase: int.tryParse(_hpBaseController.text) ?? 10,
          goldInitial:
              double.tryParse(
                _goldInitialController.text.replaceAll(',', '.'),
              ) ??
              0.0,
        );
        if (newAbility != null) {
          await _classService.addAbility(
            widget.classId!,
            name: newAbility['name']!,
            description: newAbility['description'],
          );
        }
      } else {
        await _classService.createClass(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          hpBase: int.tryParse(_hpBaseController.text) ?? 10,
          goldInitial:
              double.tryParse(
                _goldInitialController.text.replaceAll(',', '.'),
              ) ??
              0.0,
          abilities: newAbility == null ? [] : [newAbility],
        );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitialData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Classe de RPG')),
        body: const LoadingIndicator(message: 'Carregando classe...'),
      );
    }

    if (_initialDataError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Classe de RPG')),
        body: ErrorView(message: _initialDataError!, onRetry: _loadClass),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Classe de RPG' : 'Nova Classe de RPG'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Características da Classe',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(30),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                AppTextField(
                  controller: _nameController,
                  label: 'Nome da Classe',
                  hint: 'Ex: Arqueiro Arcano, Necromante, Monge',
                  validator: (v) =>
                      AppValidators.requiredField(v, 'Nome da classe'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Descrição e Arquétipo',
                  hint: 'Estilo de luta, papel no grupo...',
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _hpBaseController,
                        label: 'HP Base',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.integerNumber(v, 'HP Base'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        controller: _goldInitialController,
                        label: 'Ouro Inicial (PO)',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.positiveNumber(v, 'Ouro inicial'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Habilidade Especial Inicial (Opcional)',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_abilities.isNotEmpty) ...[
                  ..._abilities.map(
                    (ability) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(ability.name),
                      subtitle: ability.description == null
                          ? null
                          : Text(ability.description!),
                      trailing: IconButton(
                        tooltip: 'Remover habilidade',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        onPressed: () => _removeAbility(ability),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                AppTextField(
                  controller: _abilityNameController,
                  label: 'Nome da Habilidade',
                  hint: 'Ex: Flecha Espectral, Toque Vampírico',
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _abilityDescController,
                  label: 'Descrição da Habilidade',
                  hint:
                      'O que acontece quando o herói ativa esta habilidade...',
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: _isEditing
                      ? 'Atualizar Classe'
                      : 'Criar Classe Personalizada',
                  icon: Icons.check,
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
