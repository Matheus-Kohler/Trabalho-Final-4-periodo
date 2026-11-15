import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../models/rpg_class_model.dart';
import '../../services/character_service.dart';
import '../../services/rpg_class_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class CharacterFormScreen extends StatefulWidget {
  const CharacterFormScreen({super.key});

  @override
  State<CharacterFormScreen> createState() => _CharacterFormScreenState();
}

class _CharacterFormScreenState extends State<CharacterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _raceController = TextEditingController(text: 'Humano');
  final _levelController = TextEditingController(text: '1');
  final _hpController = TextEditingController(text: '12');
  final _strengthController = TextEditingController(text: '14');
  final _dexterityController = TextEditingController(text: '12');
  final _constitutionController = TextEditingController(text: '14');
  final _intelligenceController = TextEditingController(text: '10');
  final _wisdomController = TextEditingController(text: '10');
  final _charismaController = TextEditingController(text: '10');
  final _goldController = TextEditingController(text: '50.00');
  final _historyController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _characterService = CharacterService();
  final _classService = RPGClassService();

  int? _selectedClassId;
  List<RPGClassModel> _classes = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _raceController.dispose();
    _levelController.dispose();
    _hpController.dispose();
    _strengthController.dispose();
    _dexterityController.dispose();
    _constitutionController.dispose();
    _intelligenceController.dispose();
    _wisdomController.dispose();
    _charismaController.dispose();
    _goldController.dispose();
    _historyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    try {
      final classes = await _classService.getClasses();
      if (mounted) {
        setState(() {
          _classes = classes;
          if (classes.isNotEmpty) {
            _selectedClassId = classes.first.id;
            _applyClassDefaults(classes.first);
          }
        });
      }
    } catch (_) {}
  }

  void _applyClassDefaults(RPGClassModel rpgClass) {
    _hpController.text = rpgClass.hpBase.toString();
    _goldController.text = rpgClass.goldInitial.toStringAsFixed(2);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = {
        'name': _nameController.text.trim(),
        'race': _raceController.text.trim(),
        'rpg_class_id': _selectedClassId,
        'level': int.tryParse(_levelController.text) ?? 1,
        'hp_current': int.tryParse(_hpController.text) ?? 10,
        'strength': int.tryParse(_strengthController.text) ?? 10,
        'dexterity': int.tryParse(_dexterityController.text) ?? 10,
        'constitution': int.tryParse(_constitutionController.text) ?? 10,
        'intelligence': int.tryParse(_intelligenceController.text) ?? 10,
        'wisdom': int.tryParse(_wisdomController.text) ?? 10,
        'charisma': int.tryParse(_charismaController.text) ?? 10,
        'gold':
            double.tryParse(_goldController.text.replaceAll(',', '.')) ?? 0.0,
        'history': _historyController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      await _characterService.createCharacter(data);
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
      appBar: AppBar(title: const Text('Criar Nova Ficha de Herói')),
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
                  'Identidade do Aventureiro',
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
                  label: 'Nome do Personagem',
                  hint: 'Ex: Thorin Machado de Prata',
                  validator: (v) => AppValidators.requiredField(v, 'Nome'),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _raceController,
                        label: 'Raça',
                        hint: 'Ex: Anão, Elfo, Humano',
                        validator: (v) =>
                            AppValidators.requiredField(v, 'Raça'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        controller: _levelController,
                        label: 'Nível',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.integerNumber(v, 'Nível'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<int>(
                  initialValue: _selectedClassId,
                  decoration: const InputDecoration(labelText: 'Classe do RPG'),
                  dropdownColor: AppColors.surface,
                  items: _classes.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.name} (HP: ${c.hpBase})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedClassId = val;
                      final selected = _classes.firstWhere((c) => c.id == val);
                      _applyClassDefaults(selected);
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Atributos de Jogo (d20)',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _hpController,
                        label: 'Pontos de Vida (HP)',
                        keyboardType: TextInputType.number,
                        validator: (v) => AppValidators.integerNumber(v, 'HP'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        controller: _goldController,
                        label: 'Ouro (PO)',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.positiveNumber(v, 'Ouro'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _strengthController,
                        label: 'Força (FOR)',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.integerNumber(v, 'Força'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        controller: _dexterityController,
                        label: 'Destreza (DES)',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.integerNumber(v, 'Destreza'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        controller: _constitutionController,
                        label: 'Constituição (CON)',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.integerNumber(v, 'Constituição'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _intelligenceController,
                        label: 'Inteligência (INT)',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.integerNumber(v, 'Inteligência'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        controller: _wisdomController,
                        label: 'Sabedoria (SAB)',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.integerNumber(v, 'Sabedoria'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        controller: _charismaController,
                        label: 'Carisma (CAR)',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            AppValidators.integerNumber(v, 'Carisma'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _historyController,
                  label: 'História e Origem',
                  hint: 'De onde veio e seus feitos heroicos...',
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Aparência e Equipamento',
                  hint: 'Equipamentos, vestimentas e cicatrizes...',
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Salvar Ficha de Herói',
                  icon: Icons.shield,
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
