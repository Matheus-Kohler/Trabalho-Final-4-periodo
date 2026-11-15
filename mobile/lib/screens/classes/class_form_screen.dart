import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../services/rpg_class_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class ClassFormScreen extends StatefulWidget {
  const ClassFormScreen({super.key});

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
  String? _errorMessage;

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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Map<String, String>> abilities = [];
      if (_abilityNameController.text.trim().isNotEmpty) {
        abilities.add({
          'name': _abilityNameController.text.trim(),
          if (_abilityDescController.text.trim().isNotEmpty)
            'description': _abilityDescController.text.trim(),
        });
      }

      await _classService.createClass(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        hpBase: int.tryParse(_hpBaseController.text) ?? 10,
        goldInitial:
            double.tryParse(_goldInitialController.text.replaceAll(',', '.')) ??
            0.0,
        abilities: abilities,
      );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
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
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Classe de RPG')),
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
                  label: 'Criar Classe Personalizada',
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
