import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/di/injection.dart';
import '../../../core/stores/auth_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

/// Tela de login do aplicativo ESIG Feed.
/// Permite que o usuário entre com suas credenciais (usuário e senha).
/// As credenciais são validadas internamente através do AuthRepository.
/// Credenciais válidas: admin/admin123, usuario/senha123, teste/teste123, esig/esig2025
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  /// Obtém a instância do AuthStore via injeção de dependência
  final AuthStore _authStore = getIt<AuthStore>();

  /// Navega para a tela principal do feed após login bem-sucedido
  void _navigateToFeed() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  /// Processa a tentativa de login do usuário.
  /// Chama o método login() do AuthStore e navega ao feed se bem-sucedido.
  Future<void> _handleLogin() async {
    final success = await _authStore.login();
    if (success && mounted) {
      _navigateToFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Elemento decorativo superior (formato arredondado com cor de destaque)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: width * 0.35,
                      height: height * 0.15,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(width * 0.2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        "ESIG Feed",
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                // Área central com formulário de login
                Container(
                  width: width,
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(width: width),
                      const SizedBox(height: 32),
                      _Forms(width: width, authStore: _authStore),
                      const SizedBox(height: 8),

                      // Exibição de mensagem de erro (observável do MobX)
                      Observer(
                        builder: (_) {
                          if (_authStore.errorMessage != null) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                _authStore.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Botão de login com estado de carregamento
                      Observer(
                        builder: (_) => _ActionButton(
                          width: width,
                          height: height,
                          isLoading: _authStore.isLoading,
                          onPressed: _handleLogin,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dica de credenciais para facilitar testes
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Credenciais para teste:',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'admin / admin123',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Elemento decorativo inferior
                Container(
                  width: width * 0.32,
                  height: height * 0.12,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(width * 0.2),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Widget do cabeçalho da tela de login.
class _Header extends StatelessWidget {
  final double width;
  const _Header({required this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width * .1,
          child: const Divider(color: AppColors.accent, thickness: 4),
        ),
        Text(
          'Login',
          style: TextStyle(
            fontSize: width * 0.1,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Widget do formulário de login.
/// Contém campos de texto para usuário e senha, vinculados ao AuthStore.
class _Forms extends StatelessWidget {
  final double width;
  final AuthStore authStore;
  const _Forms({required this.width, required this.authStore});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de nome de usuário
        TextField(
          onChanged: authStore.setUsername,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Usuário',
            filled: true,
            hintStyle: TextStyle(color: AppColors.textHint),
            fillColor: Colors.transparent,
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent, width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Campo de senha (texto oculto)
        TextField(
          onChanged: authStore.setPassword,
          obscureText: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Senha',
            filled: true,
            hintStyle: TextStyle(color: AppColors.textHint),
            fillColor: Colors.transparent,
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botão de ação para efetuar o login.
/// Exibe um indicador de carregamento enquanto o login está em processamento.
class _ActionButton extends StatelessWidget {
  final double width;
  final double height;
  final bool isLoading;
  final VoidCallback onPressed;
  const _ActionButton({
    required this.width,
    required this.height,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        fixedSize: Size(width, height * 0.05),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.primaryDark,
                strokeWidth: 2,
              ),
            )
          : const Text("Entrar", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
