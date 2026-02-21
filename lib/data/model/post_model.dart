/// Modelo de dados que representa um post no feed.
/// Contém informações do usuário, imagens, interações e localização.
class PostModel {
  final String id;
  final String username;
  final String avatarUrl;
  final String subtitle;
  final List<String> imageUrls;
  final int likes;
  final int comments;
  final int shares;
  final int sends;
  final String date;
  final bool isLiked;
  final bool isSaved;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  PostModel({
    required this.id,
    required this.username,
    this.avatarUrl = '',
    this.subtitle = '',
    required this.imageUrls,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.sends = 0,
    this.date = '',
    this.isLiked = false,
    this.isSaved = false,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  /// Cria uma cópia do post com campos opcionalmente alterados.
  PostModel copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? subtitle,
    List<String>? imageUrls,
    int? likes,
    int? comments,
    int? shares,
    int? sends,
    String? date,
    bool? isLiked,
    bool? isSaved,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return PostModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      subtitle: subtitle ?? this.subtitle,
      imageUrls: imageUrls ?? this.imageUrls,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      sends: sends ?? this.sends,
      date: date ?? this.date,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }

  /// Converte o modelo para um Map JSON para persistência local.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
      'subtitle': subtitle,
      'imageUrls': imageUrls,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'sends': sends,
      'date': date,
      'isLiked': isLiked,
      'isSaved': isSaved,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
    };
  }

  /// Cria um PostModel a partir de um Map JSON (persistência local).
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      sends: json['sends'] ?? 0,
      date: json['date'] ?? '',
      isLiked: json['isLiked'] ?? false,
      isSaved: json['isSaved'] ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'],
    );
  }

  /// Cria um PostModel a partir da resposta da API JSONPlaceholder (/photos).
  /// Mapeia os campos da API para o formato do feed social.
  factory PostModel.fromApiJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title'] ?? '';
    // A URL da API retorna placeholder.com que pode não carregar, usaremos picsum.photos
    final imageUrl = 'https://picsum.photos/seed/photo$id/600/600';
    final thumbnailUrl = 'https://picsum.photos/seed/photo$id/150/150';

    // Gera nomes de usuário fictícios baseados no albumId
    final albumId = json['albumId'] ?? 1;
    final usernames = [
      'carlos.dev',
      'ana_fotografia',
      'marcos_viagem',
      'julia_fitness',
      'pedro_arte',
      'lucia_design',
      'rafael_music',
      'marina_cook',
      'bruno_tech',
      'camila_style',
    ];
    final username = usernames[(albumId - 1) % usernames.length];

    return PostModel(
      id: id,
      username: username,
      avatarUrl: thumbnailUrl,
      subtitle: title,
      imageUrls: [imageUrl],
      likes: (int.tryParse(id) ?? 1) * 17 % 500 + 10,
      comments: (int.tryParse(id) ?? 1) * 7 % 100,
      shares: (int.tryParse(id) ?? 1) * 3 % 50,
      sends: (int.tryParse(id) ?? 1) * 5 % 30,
      date: '${(int.tryParse(id) ?? 1) % 28 + 1} de fevereiro',
    );
  }
}
