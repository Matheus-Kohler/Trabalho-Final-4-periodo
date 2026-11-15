import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
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
  int _currentIndex = 0;
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
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      context.goNamed(AppRoutes.login);
    }
  }

  final List<Widget> _tabs = const [
    CampaignsListScreen(),
    CharactersListScreen(),
    ClassesListScreen(),
  ];

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
            tooltip: 'Sair',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _tabs),
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
