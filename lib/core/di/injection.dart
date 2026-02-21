import 'package:get_it/get_it.dart';

import '../stores/auth_store.dart';
import '../stores/post_store.dart';

/// Instância global do GetIt para injeção de dependência.
/// Permite acessar os stores de qualquer lugar do app.
final getIt = GetIt.instance;

/// Configura a injeção de dependência registrando os stores como singletons.
/// O AuthStore gerencia autenticação e o PostStore gerencia os posts do feed.
/// Utiliza lazy singleton para instanciar sob demanda.
void setupInjection() {
  getIt.registerLazySingleton<AuthStore>(() => AuthStore());
  getIt.registerLazySingleton<PostStore>(() => PostStore());
}
