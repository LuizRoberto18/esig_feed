import 'package:mobx/mobx.dart';

import '../../data/repository/auth_repository.dart';

part 'auth_store.g.dart';

/// Store MobX responsável pelo gerenciamento do estado de autenticação.
/// Controla o fluxo de login/logout do usuário, validando as credenciais
/// através do AuthRepository (função de validação à parte).
class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  /// Repositório que contém as credenciais cadastradas e a lógica de validação
  final AuthRepository _authRepository = AuthRepository();

  /// Nome de usuário digitado no campo de login
  @observable
  String username = '';

  /// Senha digitada no campo de login
  @observable
  String password = '';

  /// Indica se o processo de login está em andamento
  @observable
  bool isLoading = false;

  /// Indica se o usuário está autenticado no sistema
  @observable
  bool isAuthenticated = false;

  /// Mensagem de erro exibida ao usuário em caso de falha no login
  @observable
  String? errorMessage;

  /// Atualiza o nome de usuário conforme digitação
  @action
  void setUsername(String value) => username = value;

  /// Atualiza a senha conforme digitação
  @action
  void setPassword(String value) => password = value;

  /// Realiza o processo de login.
  /// Valida se os campos foram preenchidos e verifica as credenciais
  /// contra os usuários cadastrados internamente no aplicativo.
  /// Retorna true se o login for bem-sucedido.
  @action
  Future<bool> login() async {
    isLoading = true;
    errorMessage = null;

    // Simula um pequeno atraso para feedback visual ao usuário
    await Future.delayed(const Duration(milliseconds: 600));

    // Validação de campos obrigatórios
    if (username.trim().isEmpty || password.trim().isEmpty) {
      errorMessage = 'Preencha todos os campos';
      isLoading = false;
      return false;
    }

    // Validação das credenciais usando a função separada no repositório
    final credenciaisValidas = _authRepository.validarCredenciais(
      username,
      password,
    );

    if (!credenciaisValidas) {
      errorMessage = 'Usuário ou senha inválidos';
      isLoading = false;
      return false;
    }

    // Login bem-sucedido
    isAuthenticated = true;
    isLoading = false;
    return true;
  }

  /// Realiza o logout do usuário, limpando todos os dados da sessão.
  @action
  void logout() {
    isAuthenticated = false;
    username = '';
    password = '';
    errorMessage = null;
  }
}
