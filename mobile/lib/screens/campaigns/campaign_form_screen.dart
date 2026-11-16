import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../models/campaign_model.dart';
import '../../services/campaign_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

class CampaignFormScreen extends StatefulWidget {
  final int? campaignId;

  const CampaignFormScreen({super.key, this.campaignId});

  @override
  State<CampaignFormScreen> createState() => _CampaignFormScreenState();
}

class _CampaignFormScreenState extends State<CampaignFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _campaignService = CampaignService();

  String _status = 'ativa';
  bool _isLoading = false;
  bool _isLoadingInitialData = false;
  String? _errorMessage;
  String? _initialDataError;

  bool get _isEditing => widget.campaignId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadCampaign();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCampaign() async {
    setState(() {
      _isLoadingInitialData = true;
      _initialDataError = null;
    });
    try {
      final CampaignModel campaign = await _campaignService.getCampaign(
        widget.campaignId!,
      );
      if (mounted) {
        setState(() {
          _nameController.text = campaign.name;
          _descriptionController.text = campaign.description ?? '';
          _status = campaign.status;
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isEditing) {
        await _campaignService.updateCampaign(
          widget.campaignId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _status,
        );
      } else {
        await _campaignService.createCampaign(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _status,
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
        appBar: AppBar(title: const Text('Editar Campanha')),
        body: const LoadingIndicator(message: 'Carregando campanha...'),
      );
    }

    if (_initialDataError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Campanha')),
        body: ErrorView(message: _initialDataError!, onRetry: _loadCampaign),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Campanha' : 'Nova Campanha'),
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
                  'Configurar Mesa de RPG',
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
                  label: 'Nome da Campanha',
                  hint: 'Ex: A Mina Perdida de Phandelver',
                  validator: (v) =>
                      AppValidators.requiredField(v, 'Nome da campanha'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Descrição e Enredo',
                  hint:
                      'Breve resumo do cenário e premissa para os aventureiros...',
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status da Campanha',
                  ),
                  dropdownColor: AppColors.surface,
                  items: const [
                    DropdownMenuItem(
                      value: 'ativa',
                      child: Text('Ativa (Em andamento)'),
                    ),
                    DropdownMenuItem(
                      value: 'pausada',
                      child: Text('Pausada (Interrompida)'),
                    ),
                    DropdownMenuItem(
                      value: 'encerrada',
                      child: Text('Encerrada (Finalizada)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: _isEditing ? 'Atualizar Campanha' : 'Criar Campanha',
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
