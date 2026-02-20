import 'package:flutter/material.dart';

import '../data/view/auth/auth_page.dart';
import '../data/view/feed/feed_page.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/feed';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const AuthPage(),
    home: (context) => const FeedPage(),
  };
}
