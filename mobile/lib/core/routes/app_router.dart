import 'package:go_router/go_router.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/campaigns/campaign_detail_screen.dart';
import '../../screens/campaigns/campaign_form_screen.dart';
import '../../screens/characters/character_form_screen.dart';
import '../../screens/classes/class_form_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/invitations/invitations_screen.dart';
import 'app_routes.dart';

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.homePath,
    routes: [
      GoRoute(
        name: AppRoutes.home,
        path: AppRoutes.homePath,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: AppRoutes.login,
        path: AppRoutes.loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: AppRoutes.register,
        path: AppRoutes.registerPath,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: AppRoutes.campaignForm,
        path: AppRoutes.campaignFormPath,
        builder: (context, state) => const CampaignFormScreen(),
      ),
      GoRoute(
        name: AppRoutes.campaignDetail,
        path: AppRoutes.campaignDetailPath,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '0';
          final id = int.tryParse(idStr) ?? 0;
          return CampaignDetailScreen(campaignId: id);
        },
      ),
      GoRoute(
        name: AppRoutes.characterForm,
        path: AppRoutes.characterFormPath,
        builder: (context, state) => const CharacterFormScreen(),
      ),
      GoRoute(
        name: AppRoutes.classForm,
        path: AppRoutes.classFormPath,
        builder: (context, state) => const ClassFormScreen(),
      ),
      GoRoute(
        name: AppRoutes.invitations,
        path: AppRoutes.invitationsPath,
        builder: (context, state) => const InvitationsScreen(),
      ),
    ],
  );
}
