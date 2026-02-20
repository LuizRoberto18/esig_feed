import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/di/injection.dart';
import '../../../core/stores/auth_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthStore _authStore = getIt<AuthStore>();

  @override
  void initState() {
    super.initState();
    _authStore.checkBiometrics();
  }

  void _navigateToFeed() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  Future<void> _handleLogin() async {
    final success = await _authStore.login();
    if (success && mounted) {
      _navigateToFeed();
    }
  }

  Future<void> _handleBiometric() async {
    final success = await _authStore.authenticateWithBiometrics();
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
                      // Error message
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
                      // Login button
                      Observer(
                        builder: (_) => _ActionButton(
                          width: width,
                          height: height,
                          isLoading: _authStore.isLoading,
                          onPressed: _handleLogin,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Biometric button
                      Observer(
                        builder: (_) {
                          if (!_authStore.canUseBiometrics) {
                            return const SizedBox.shrink();
                          }
                          return Center(
                            child: GestureDetector(
                              onTap: _authStore.isBiometricLoading
                                  ? null
                                  : _handleBiometric,
                              child: Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.accent,
                                        width: 2,
                                      ),
                                    ),
                                    child: _authStore.isBiometricLoading
                                        ? const Padding(
                                            padding: EdgeInsets.all(16),
                                            child: CircularProgressIndicator(
                                              color: AppColors.accent,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.fingerprint,
                                            color: AppColors.accent,
                                            size: 36,
                                          ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Entrar com biometria',
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
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

class _Forms extends StatelessWidget {
  final double width;
  final AuthStore authStore;
  const _Forms({required this.width, required this.authStore});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        backgroundColor: AppColors.accent,
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
