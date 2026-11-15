import 'package:flutter/foundation.dart';

abstract class AppConstants {
  /// Nome do aplicativo.
  static const String appName = 'RPG Manager';

  /// URL base da API REST do Laravel.
  /// No Android Emulator, 10.0.2.2 aponta para o localhost da máquina host.
  /// No Windows / Web / Linux / macOS, usa 127.0.0.1.
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  /// Chave de persistência do token de autenticação.
  static const String tokenStorageKey = 'rpg_manager_auth_token';

  /// Chave de persistência dos dados do usuário logado.
  static const String userStorageKey = 'rpg_manager_user_data';

  /// Textos de interface padronizados.
  static const String loadingText = 'Carregando aventuras...';
  static const String errorDefaultText =
      'Ocorreu uma falha na conexão com o reino.';
  static const String retryButtonText = 'Tentar novamente';
  static const String emptyCampaignsText =
      'Nenhuma campanha encontrada no reino.';
  static const String emptyPlayerCampaignsText =
      'Você ainda não foi convidado para nenhuma campanha como jogador.';
  static const String emptyCharactersText = 'Nenhum herói foi recrutado ainda.';
  static const String emptyClassesText =
      'Nenhuma classe de RPG personalizada criada.';
  static const String emptyInvitationsText =
      'Você não tem nenhum convite pendente no momento.';
  static const String emptyCampaignCharactersText =
      'Nenhum personagem vinculado a esta mesa.';
  static const String emptyCampaignClassesText =
      'Nenhuma classe foi disponibilizada pelo mestre ainda.';
}
