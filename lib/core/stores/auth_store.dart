import 'package:local_auth/local_auth.dart';
import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @observable
  String username = '';

  @observable
  String password = '';

  @observable
  bool isLoading = false;

  @observable
  bool isAuthenticated = false;

  @observable
  String? errorMessage;

  @observable
  bool canUseBiometrics = false;

  @observable
  bool isBiometricLoading = false;

  @action
  void setUsername(String value) => username = value;

  @action
  void setPassword(String value) => password = value;

  @action
  Future<void> checkBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      canUseBiometrics = isAvailable && isDeviceSupported;
    } catch (_) {
      canUseBiometrics = false;
    }
  }

  @action
  Future<bool> authenticateWithBiometrics() async {
    isBiometricLoading = true;
    errorMessage = null;
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Use sua biometria para acessar o ESIG Feed',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        isAuthenticated = true;
      }
      isBiometricLoading = false;
      return authenticated;
    } catch (e) {
      errorMessage = 'Erro na autenticação biométrica';
      isBiometricLoading = false;
      return false;
    }
  }

  @action
  Future<bool> login() async {
    isLoading = true;
    errorMessage = null;

    // Simulated login validation
    await Future.delayed(const Duration(milliseconds: 800));

    if (username.trim().isEmpty || password.trim().isEmpty) {
      errorMessage = 'Preencha todos os campos';
      isLoading = false;
      return false;
    }

    // Simple mock validation
    isAuthenticated = true;
    isLoading = false;
    return true;
  }

  @action
  void logout() {
    isAuthenticated = false;
    username = '';
    password = '';
    errorMessage = null;
  }
}
