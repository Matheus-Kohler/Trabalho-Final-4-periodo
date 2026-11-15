import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        context.goNamed(AppRoutes.home);
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
      appBar: AppBar(title: const Text('Novo Aventureiro')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_outlined,
                      color: AppColors.secondary,
                      size: 56,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Criar Nova Conta',
                      style: AppTextStyles.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Junte-se às campanhas do ${AppConstants.appName}',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(30),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    AppTextField(
                      controller: _nameController,
                      label: 'Nome de herói ou mestre',
                      prefixIcon: const Icon(
                        Icons.badge_outlined,
                        color: AppColors.textSecondary,
                      ),
                      validator: (v) => AppValidators.requiredField(v, 'Nome'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _emailController,
                      label: 'Endereço de e-mail',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.textSecondary,
                      ),
                      validator: AppValidators.email,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Senha (mínimo 6 caracteres)',
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textSecondary,
                      ),
                      validator: (v) =>
                          AppValidators.minLength(v, 6, 'A senha'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Concluir Cadastro',
                      isLoading: _isLoading,
                      icon: Icons.check,
                      onPressed: _handleRegister,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
