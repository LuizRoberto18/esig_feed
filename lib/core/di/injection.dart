import 'package:get_it/get_it.dart';

import '../stores/auth_store.dart';
import '../stores/post_store.dart';

final getIt = GetIt.instance;

void setupInjection() {
  getIt.registerLazySingleton<AuthStore>(() => AuthStore());
  getIt.registerLazySingleton<PostStore>(() => PostStore());
}
