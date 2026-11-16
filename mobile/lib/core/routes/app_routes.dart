abstract class AppRoutes {
  static const String login = 'login';
  static const String loginPath = '/login';

  static const String register = 'register';
  static const String registerPath = '/register';

  static const String home = 'home';
  static const String homePath = '/';

  static const String campaigns = 'campaigns';
  static const String campaignsPath = '/campaigns';

  static const String campaignDetail = 'campaign-detail';
  static const String campaignDetailPath = '/campaigns/:id';

  static const String campaignForm = 'campaign-form';
  static const String campaignFormPath = '/campaigns/form';

  static const String campaignEdit = 'campaign-edit';
  static const String campaignEditPath = '/campaigns/:id/edit';

  static const String characters = 'characters';
  static const String charactersPath = '/characters';

  static const String characterForm = 'character-form';
  static const String characterFormPath = '/characters/form';

  static const String characterEdit = 'character-edit';
  static const String characterEditPath = '/characters/:id/edit';

  static const String classes = 'classes';
  static const String classesPath = '/classes';

  static const String classForm = 'class-form';
  static const String classFormPath = '/classes/form';

  static const String classEdit = 'class-edit';
  static const String classEditPath = '/classes/:id/edit';

  static const String invitations = 'invitations';
  static const String invitationsPath = '/invitations';
}
