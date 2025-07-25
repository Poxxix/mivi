import 'package:equatable/equatable.dart';

/// Model đại diện cho một bộ phim trong ứng dụng
/// Chứa tất cả thông tin cần thiết về phim như title, cast, rating, etc.
class Movie extends Equatable {
  // Thông tin cơ bản của phim
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<Genre> genres;
  
  // Trạng thái và dữ liệu bổ sung
  final bool isFavorite;
  final List<CastMember> cast;
  final List<Movie> similarMovies;
  final String? trailerUrl;
  final int runtime;
  final String? tagline;
  final String? status;
  final String? originalLanguage;
  final double? budget;
  final double? revenue;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genres,
    this.isFavorite = false,
    this.cast = const [],
    this.similarMovies = const [],
    this.trailerUrl,
    this.runtime = 0,
    this.tagline,
    this.status,
    this.originalLanguage,
    this.budget,
    this.revenue,
  });

  /// Lấy năm phát hành từ ngày release
  String get releaseYear {
    try {
      return releaseDate.split('-')[0];
    } catch (e) {
      return 'N/A';
    }
  }
  
  /// Chuyển đổi danh sách genres thành chuỗi, phân cách bằng dấu phẩy
  String get genresAsString {
    if (genres.isEmpty) return 'Chưa phân loại';
    return genres.map((genre) => genre.name).join(', ');
  }
  
  /// Format thời lượng phim từ phút sang giờ:phút
  String get formattedDuration {
    if (runtime <= 0) return 'Chưa có thông tin';
    
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Format ngân sách phim với đơn vị phù hợp (K, M, B)
  String get formattedBudget {
    if (budget == null || budget! <= 0) return 'Chưa có thông tin';
    
    if (budget! >= 1000000000) {
      return '\$${(budget! / 1000000000).toStringAsFixed(1)}B';
    } else if (budget! >= 1000000) {
      return '\$${(budget! / 1000000).toStringAsFixed(1)}M';
    } else if (budget! >= 1000) {
      return '\$${(budget! / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${budget!.toStringAsFixed(0)}';
    }
  }

  /// Format doanh thu phim với đơn vị phù hợp (K, M, B)
  String get formattedRevenue {
    if (revenue == null || revenue! <= 0) return 'Chưa có thông tin';
    
    if (revenue! >= 1000000000) {
      return '\$${(revenue! / 1000000000).toStringAsFixed(1)}B';
    } else if (revenue! >= 1000000) {
      return '\$${(revenue! / 1000000).toStringAsFixed(1)}M';
    } else if (revenue! >= 1000) {
      return '\$${(revenue! / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${revenue!.toStringAsFixed(0)}';
    }
  }

  /// Tạo bản sao của movie với các thuộc tính được cập nhật
  Movie copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    String? releaseDate,
    List<Genre>? genres,
    bool? isFavorite,
    List<CastMember>? cast,
    List<Movie>? similarMovies,
    String? trailerUrl,
    int? runtime,
    String? tagline,
    String? status,
    String? originalLanguage,
    double? budget,
    double? revenue,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      releaseDate: releaseDate ?? this.releaseDate,
      genres: genres ?? this.genres,
      isFavorite: isFavorite ?? this.isFavorite,
      cast: cast ?? this.cast,
      similarMovies: similarMovies ?? this.similarMovies,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      runtime: runtime ?? this.runtime,
      tagline: tagline ?? this.tagline,
      status: status ?? this.status,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      budget: budget ?? this.budget,
      revenue: revenue ?? this.revenue,
    );
  }

  /// Chuyển đổi movie thành JSON để lưu trữ hoặc truyền tải
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'voteAverage': voteAverage,
      'releaseDate': releaseDate,
      'genres': genres.map((genre) => genre.toJson()).toList(),
      'isFavorite': isFavorite,
      'cast': cast.map((member) => member.toJson()).toList(),
      'similarMovies': similarMovies.map((movie) => movie.toJson()).toList(),
      'trailerUrl': trailerUrl,
      'runtime': runtime,
      'tagline': tagline,
      'status': status,
      'originalLanguage': originalLanguage,
      'budget': budget,
      'revenue': revenue,
    };
  }

  /// Tạo movie từ JSON data
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['posterPath'] ?? '',
      backdropPath: json['backdropPath'] ?? '',
      voteAverage: (json['voteAverage'] ?? 0.0).toDouble(),
      releaseDate: json['releaseDate'] ?? '',
      genres: (json['genres'] as List<dynamic>?)
          ?.map((g) => Genre.fromJson(g))
          .toList() ?? [],
      isFavorite: json['isFavorite'] ?? false,
      cast: (json['cast'] as List<dynamic>?)
          ?.map((c) => CastMember.fromJson(c))
          .toList() ?? [],
      similarMovies: (json['similarMovies'] as List<dynamic>?)
          ?.map((m) => Movie.fromJson(m))
          .toList() ?? [],
      trailerUrl: json['trailerUrl'],
      runtime: json['runtime'] ?? 0,
      tagline: json['tagline'],
      status: json['status'],
      originalLanguage: json['originalLanguage'],
      budget: json['budget']?.toDouble(),
      revenue: json['revenue']?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    overview,
    posterPath,
    backdropPath,
    voteAverage,
    releaseDate,
    genres,
    isFavorite,
    cast,
    similarMovies,
    trailerUrl,
    runtime,
    tagline,
    status,
    originalLanguage,
    budget,
    revenue,
  ];
}

/// Model đại diện cho thể loại phim
class Genre extends Equatable {
  final int id;
  final String name;

  const Genre({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Model đại diện cho thành viên trong dàn diễn viên
class CastMember extends Equatable {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    this.order = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'character': character,
      'profilePath': profilePath,
      'order': order,
    };
  }

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: json['profilePath'],
      order: json['order'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, character, profilePath, order];
} 