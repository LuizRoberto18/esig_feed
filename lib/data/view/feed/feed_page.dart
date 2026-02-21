import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/di/injection.dart';
import '../../../core/stores/auth_store.dart';
import '../../../core/stores/post_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../model/post_model.dart';
import '../widgets/post_card.dart';
import '../widgets/stories_bar.dart';
import 'post_detail_page.dart';
import 'post_form_page.dart';

/// Tela principal do feed de postagens.
/// Exibe a listagem de posts em formato de cards, similar a uma rede social.
/// Permite criar, editar e excluir posts, além de navegar para detalhes.
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  /// Store de posts para gerenciar o estado do feed
  final PostStore _postStore = getIt<PostStore>();

  /// Store de autenticação para funcionalidade de logout
  final AuthStore _authStore = getIt<AuthStore>();

  @override
  void initState() {
    super.initState();
    // Carrega os posts ao inicializar (da API ou armazenamento local)
    _postStore.loadPosts();
  }

  /// Navega para a tela de criação de novo post.
  /// Ao retornar com dados, adiciona o post ao feed.
  Future<void> _addPost() async {
    final result = await Navigator.push<PostModel>(
      context,
      MaterialPageRoute(builder: (_) => const PostFormPage()),
    );
    if (result != null) {
      await _postStore.addPost(result);
    }
  }

  /// Navega para a tela de edição de um post existente.
  /// Ao retornar com dados, atualiza o post no feed.
  Future<void> _editPost(PostModel post) async {
    final result = await Navigator.push<PostModel>(
      context,
      MaterialPageRoute(builder: (_) => PostFormPage(post: post)),
    );
    if (result != null) {
      await _postStore.updatePost(result);
    }
  }

  /// Exclui um post do feed e exibe confirmação ao usuário.
  Future<void> _deletePost(String id) async {
    await _postStore.deletePost(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Postagem excluída'),
          backgroundColor: AppColors.primaryDark.withOpacity(0.9),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Navega para a tela de detalhes de um post.
  /// Permite visualizar informações completas e editar a partir dela.
  Future<void> _viewPostDetails(PostModel post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
    );
    // Se o post foi excluído na tela de detalhes, recarrega a lista
    if (result == true) {
      await _postStore.loadPosts();
    }
  }

  /// Realiza o logout do usuário e retorna à tela de login.
  void _logout() {
    _authStore.logout();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: const Text(
          'ESIG Feed',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
            fontSize: 24,
          ),
        ),
        actions: [
          // Botão para criar nova postagem
          IconButton(
            onPressed: _addPost,
            icon: const Icon(
              Icons.add_box_outlined,
              color: AppColors.accent,
              size: 26,
            ),
            tooltip: 'Nova postagem',
          ),
          // Botão de notificações (curtidas)
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.favorite_border,
              color: AppColors.textPrimary,
              size: 26,
            ),
          ),
          // Botão de logout
          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
              color: AppColors.textPrimary,
              size: 24,
            ),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          final posts = _postStore.posts;

          // Indicador de carregamento enquanto busca os posts
          if (_postStore.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          // Estado vazio quando não há postagens
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.primaryLight.withOpacity(0.5),
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma postagem ainda',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toque no + para criar sua primeira postagem',
                    style: TextStyle(color: AppColors.textHint, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          // Lista de posts com barra de stories no topo
          return ListView.builder(
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
              // Primeiro item é a barra de stories
              if (index == 0) {
                return Column(
                  children: [
                    const StoriesBar(),
                    Divider(
                      color: AppColors.primaryDark.withOpacity(0.5),
                      height: 1,
                    ),
                  ],
                );
              }

              // Cards de posts com ações de CRUD
              final post = posts[index - 1];
              return PostCard(
                post: post,
                onEdit: () => _editPost(post),
                onDelete: () => _deletePost(post.id),
                onToggleLike: () => _postStore.toggleLike(post.id),
                onToggleSave: () => _postStore.toggleSave(post.id),
                onTap: () => _viewPostDetails(post),
              );
            },
          );
        },
      ),

      // Barra de navegação inferior com ações rápidas
      bottomNavigationBar: _BottomNavigationBar(onAddPost: _addPost),
    );
  }
}

/// Constrói a barra de navegação inferior do feed.
class _BottomNavigationBar extends StatelessWidget {
  final VoidCallback onAddPost;
  const _BottomNavigationBar({required this.onAddPost});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        border: Border(
          top: BorderSide(
            color: AppColors.primaryLight.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Ícone do feed (página atual)
              const Icon(Icons.home_filled, color: AppColors.accent, size: 28),
              const Icon(
                Icons.play_circle_outline,
                color: AppColors.textSecondary,
                size: 28,
              ),
              // Botão de criar post na barra inferior
              GestureDetector(
                onTap: onAddPost,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.accent,
                    size: 22,
                  ),
                ),
              ),
              const Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 28,
              ),
              // Ícone de perfil do usuário
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(
                  Icons.person,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
