/// Repositório de autenticação do aplicativo.
/// Gerencia as credenciais de login cadastradas internamente.
/// As credenciais são validadas em uma função à parte, separando
/// a lógica de autenticação da interface do usuário.
class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  /// Lista de credenciais cadastradas internamente no aplicativo.
  /// Cada entrada contém um nome de usuário e uma senha.
  /// Em produção, essas credenciais seriam armazenadas de forma segura.
  static final List<Map<String, String>> _credenciaisCadastradas = [
    {'username': 'admin', 'password': 'admin123'},
    {'username': 'usuario', 'password': 'senha123'},
    {'username': 'teste', 'password': 'teste123'},
    {'username': 'esig', 'password': 'esig2025'},
  ];

  /// Função de validação de credenciais.
  /// Verifica se o usuário e senha informados correspondem a algum
  /// cadastro interno do aplicativo.
  /// Retorna true se as credenciais forem válidas, false caso contrário.
  bool validarCredenciais(String username, String password) {
    return _credenciaisCadastradas.any(
      (credencial) =>
          credencial['username'] == username.trim() &&
          credencial['password'] == password.trim(),
    );
  }

  /// Retorna o nome de exibição do usuário autenticado.
  /// Capitaliza a primeira letra do username para exibição.
  String getNomeExibicao(String username) {
    if (username.isEmpty) return '';
    return username[0].toUpperCase() + username.substring(1);
  }
}
