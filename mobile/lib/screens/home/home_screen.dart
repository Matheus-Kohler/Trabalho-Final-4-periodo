import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/campaign_invitation_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/invitation_service.dart';
import '../campaigns/campaigns_list_screen.dart';
import '../characters/characters_list_screen.dart';
import '../classes/classes_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _invitationService = InvitationService();
  int _currentIndex = 0;
  int _refreshKey = 0;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
      // Verifica convites pendentes e exibe popup obrigatório caso haja
      _checkPendingInvitations();
    }
  }

  Future<void> _checkPendingInvitations() async {
    try {
      final pending = await _invitationService.getPendingInvitations();
      if (!mounted || pending.isEmpty) return;

      for (final inv in pending) {
        if (!mounted) break;
        await _showMandatoryInvitationDialog(inv);
      }
    } catch (_) {}
  }

  Future<void> _showMandatoryInvitationDialog(CampaignInvitationModel inv) async {
    final campaignName = inv.campaign?.name ?? 'Campanha #${inv.campaignId}';
    final charName = inv.character?.name ?? 'seu personagem';
    final masterName = inv.campaign?.master?.name ?? 'O mestre';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mail, color: AppColors.secondary),
            SizedBox(width: 8),
            Text('Convite de Campanha!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$masterName convidou seu personagem $charName para participar da campanha:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaignName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.secondary,
                    ),
                  ),
                  if (inv.campaign?.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      inv.campaign!.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Você deve decidir se aceita entrar na aventura agora para prosseguir:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _invitationService.rejectInvitation(inv.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Convite recusado.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('Recusar', style: TextStyle(color: AppColors.error)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.textPrimary,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _invitationService.acceptInvitation(inv.id);
                if (mounted) {
                  setState(() {
                    _refreshKey++;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Convite aceito com sucesso! Bem-vindo à campanha.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('Aceitar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      context.goNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Campanhas de RPG'
              : _currentIndex == 1
              ? 'Fichas de Personagens'
              : 'Classes do Sistema',
        ),
        actions: [
          if (_currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  _currentUser!.name,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Atualizar dados',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _refreshKey++;
              });
              _checkPendingInvitations();
            },
          ),
          IconButton(
            tooltip: 'Convites de Campanha',
            icon: const Icon(Icons.mail_outline),
            onPressed: () async {
              await context.pushNamed(AppRoutes.invitations);
              setState(() {
                _refreshKey++;
              });
              _checkPendingInvitations();
            },
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CampaignsListScreen(key: ValueKey('campaigns_$_refreshKey')),
          CharactersListScreen(key: ValueKey('characters_$_refreshKey')),
          ClassesListScreen(key: ValueKey('classes_$_refreshKey')),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.castle_outlined),
            selectedIcon: Icon(Icons.castle),
            label: 'Campanhas',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Personagens',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_fix_high_outlined),
            selectedIcon: Icon(Icons.auto_fix_high),
            label: 'Classes',
          ),
        ],
      ),
    );
  }
}
