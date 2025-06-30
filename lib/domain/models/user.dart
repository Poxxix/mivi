class User {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final List<String> favoriteMovies;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.favoriteMovies = const [],
  });

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    List<String>? favoriteMovies,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
    );
  }
} 