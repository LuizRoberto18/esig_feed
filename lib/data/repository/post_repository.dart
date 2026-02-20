import '../model/post_model.dart';

class PostRepository {
  static final PostRepository _instance = PostRepository._internal();
  factory PostRepository() => _instance;
  PostRepository._internal() {
    _posts = _generateSamplePosts();
  }

  late List<PostModel> _posts;
  int _nextId = 10;

  List<PostModel> getAll() => List.unmodifiable(_posts);

  PostModel? getById(String id) {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void add(PostModel post) {
    final newPost = post.copyWith(id: (_nextId++).toString());
    _posts.insert(0, newPost);
  }

  void update(PostModel post) {
    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      _posts[index] = post;
    }
  }

  void delete(String id) {
    _posts.removeWhere((p) => p.id == id);
  }

  void toggleLike(String id) {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        isLiked: !post.isLiked,
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
      );
    }
  }

  void toggleSave(String id) {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(isSaved: !post.isSaved);
    }
  }

  List<PostModel> _generateSamplePosts() {
    return [
      PostModel(
        id: '1',
        username: 'stephannysilveira_',
        subtitle: 'Sugestões para você',
        imageUrls: [
          'https://picsum.photos/seed/beach1/600/600',
          'https://picsum.photos/seed/beach2/600/600',
          'https://picsum.photos/seed/beach3/600/600',
        ],
        likes: 1218,
        comments: 47,
        shares: 6,
        sends: 27,
        date: '2 de fevereiro',
      ),
      PostModel(
        id: '2',
        username: 'carlos.dev',
        subtitle: 'São Paulo, Brasil',
        imageUrls: ['https://picsum.photos/seed/city1/600/600'],
        likes: 532,
        comments: 23,
        shares: 2,
        sends: 12,
        date: '5 de fevereiro',
      ),
      PostModel(
        id: '3',
        username: 'ana_fotografia',
        subtitle: 'Fotógrafa profissional',
        imageUrls: [
          'https://picsum.photos/seed/nature1/600/600',
          'https://picsum.photos/seed/nature2/600/600',
        ],
        likes: 3450,
        comments: 89,
        shares: 15,
        sends: 42,
        date: '10 de fevereiro',
      ),
      PostModel(
        id: '4',
        username: 'marcos_viagem',
        subtitle: 'Rio de Janeiro',
        imageUrls: [
          'https://picsum.photos/seed/travel1/600/600',
          'https://picsum.photos/seed/travel2/600/600',
          'https://picsum.photos/seed/travel3/600/600',
          'https://picsum.photos/seed/travel4/600/600',
        ],
        likes: 876,
        comments: 34,
        shares: 8,
        sends: 19,
        date: '14 de fevereiro',
      ),
      PostModel(
        id: '5',
        username: 'julia_fitness',
        subtitle: 'Personal Trainer',
        imageUrls: ['https://picsum.photos/seed/fitness1/600/600'],
        likes: 2100,
        comments: 56,
        shares: 20,
        sends: 35,
        date: '18 de fevereiro',
      ),
    ];
  }
}
