import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/di/injection.dart';
import '../../../core/stores/post_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../model/post_model.dart';
import '../widgets/post_card.dart';
import '../widgets/stories_bar.dart';
import 'post_form_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final PostStore _postStore = getIt<PostStore>();

  @override
  void initState() {
    super.initState();
    _postStore.loadPosts();
  }

  Future<void> _addPost() async {
    final result = await Navigator.push<PostModel>(
      context,
      MaterialPageRoute(builder: (_) => const PostFormPage()),
    );
    if (result != null) {
      _postStore.addPost(result);
    }
  }

  Future<void> _editPost(PostModel post) async {
    final result = await Navigator.push<PostModel>(
      context,
      MaterialPageRoute(builder: (_) => PostFormPage(post: post)),
    );
    if (result != null) {
      _postStore.updatePost(result);
    }
  }

  void _deletePost(String id) {
    _postStore.deletePost(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Postagem excluída'),
        backgroundColor: AppColors.primaryDark.withOpacity(0.9),
        duration: const Duration(seconds: 2),
      ),
    );
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
          IconButton(
            onPressed: _addPost,
            icon: const Icon(
              Icons.add_box_outlined,
              color: AppColors.accent,
              size: 26,
            ),
            tooltip: 'Nova postagem',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.favorite_border,
              color: AppColors.textPrimary,
              size: 26,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.send_outlined,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          final posts = _postStore.posts;

          if (_postStore.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

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

          return ListView.builder(
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
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

              final post = posts[index - 1];
              return PostCard(
                post: post,
                onEdit: () => _editPost(post),
                onDelete: () => _deletePost(post.id),
                onToggleLike: () => _postStore.toggleLike(post.id),
                onToggleSave: () => _postStore.toggleSave(post.id),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
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
              const Icon(Icons.home_filled, color: AppColors.accent, size: 28),
              const Icon(
                Icons.play_circle_outline,
                color: AppColors.textSecondary,
                size: 28,
              ),
              GestureDetector(
                onTap: _addPost,
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
