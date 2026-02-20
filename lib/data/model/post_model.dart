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
}
