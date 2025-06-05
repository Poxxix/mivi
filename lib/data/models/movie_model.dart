import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<Genre> genres;
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

  String get year => releaseDate.split('-')[0];
  
  String get genresString => genres.map((g) => g.name).join(', ');
  
  String get formattedRuntime {
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return '${hours}h ${minutes}m';
  }

  String get formattedBudget {
    if (budget == null) return 'N/A';
    if (budget! >= 1000000) {
      return '\$${(budget! / 1000000).toStringAsFixed(1)}M';
    }
    return '\$${(budget! / 1000).toStringAsFixed(1)}K';
  }

  String get formattedRevenue {
    if (revenue == null) return 'N/A';
    if (revenue! >= 1000000) {
      return '\$${(revenue! / 1000000).toStringAsFixed(1)}M';
    }
    return '\$${(revenue! / 1000).toStringAsFixed(1)}K';
  }

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

class Genre extends Equatable {
  final int id;
  final String name;

  const Genre({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

class CastMember extends Equatable {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  @override
  List<Object?> get props => [id, name, character, profilePath];
} 