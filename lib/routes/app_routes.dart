import 'package:flutter/material.dart';

import '../data/view/auth/auth_page.dart';
import '../data/view/feed/feed_page.dart';

/// Classe que centraliza as rotas nomeadas do aplicativo.
/// Define os caminhos e mapeia cada rota para sua respectiva tela.
class AppRoutes {
  static const String login = '/';

  static const String home = '/feed';

  /// Mapa de rotas do aplicativo, vinculando cada caminho à sua tela
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const AuthPage(),
    home: (context) => const FeedPage(),
  };
}
