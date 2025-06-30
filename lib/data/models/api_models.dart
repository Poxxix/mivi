import 'package:json_annotation/json_annotation.dart';

part 'api_models.g.dart';

@JsonSerializable()
class MovieResponse {
  final int? page;
  final List<MovieDto>? results;
  final int? totalPages;
  final int? totalResults;

  MovieResponse({
    this.page,
    this.results,
    this.totalPages,
    this.totalResults,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MovieResponseToJson(this);
}

@JsonSerializable()
class MovieDto {
  final int id;
  final String title;
  final String overview;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @JsonKey(name: 'vote_average')
  final double? voteAverage;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'genre_ids')
  final List<int>? genreIds;
  final bool? adult;
  @JsonKey(name: 'original_language')
  final String? originalLanguage;
  @JsonKey(name: 'original_title')
  final String? originalTitle;
  final double? popularity;
  @JsonKey(name: 'vote_count')
  final int? voteCount;
  @JsonKey(name: 'video')
  final bool? video;

  MovieDto({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.releaseDate,
    this.genreIds,
    this.adult,
    this.originalLanguage,
    this.originalTitle,
    this.popularity,
    this.voteCount,
    this.video,
  });

  factory MovieDto.fromJson(Map<String, dynamic> json) =>
      _$MovieDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MovieDtoToJson(this);
}

@JsonSerializable()
class MovieDetailDto {
  final int id;
  final String title;
  final String overview;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @JsonKey(name: 'vote_average')
  final double? voteAverage;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  final List<GenreDto>? genres;
  final bool? adult;
  @JsonKey(name: 'original_language')
  final String? originalLanguage;
  @JsonKey(name: 'original_title')
  final String? originalTitle;
  final double? popularity;
  @JsonKey(name: 'vote_count')
  final int? voteCount;
  final int? runtime;
  final String? tagline;
  final String? status;
  final double? budget;
  final double? revenue;
  @JsonKey(name: 'production_companies')
  final List<ProductionCompanyDto>? productionCompanies;

  MovieDetailDto({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.releaseDate,
    this.genres,
    this.adult,
    this.originalLanguage,
    this.originalTitle,
    this.popularity,
    this.voteCount,
    this.runtime,
    this.tagline,
    this.status,
    this.budget,
    this.revenue,
    this.productionCompanies,
  });

  factory MovieDetailDto.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MovieDetailDtoToJson(this);
}

@JsonSerializable()
class GenreDto {
  final int id;
  final String name;

  GenreDto({
    required this.id,
    required this.name,
  });

  factory GenreDto.fromJson(Map<String, dynamic> json) =>
      _$GenreDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GenreDtoToJson(this);
}

@JsonSerializable()
class ProductionCompanyDto {
  final int id;
  final String name;
  @JsonKey(name: 'logo_path')
  final String? logoPath;
  @JsonKey(name: 'origin_country')
  final String? originCountry;

  ProductionCompanyDto({
    required this.id,
    required this.name,
    this.logoPath,
    this.originCountry,
  });

  factory ProductionCompanyDto.fromJson(Map<String, dynamic> json) =>
      _$ProductionCompanyDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProductionCompanyDtoToJson(this);
}

@JsonSerializable()
class CreditsResponse {
  final int id;
  final List<CastDto>? cast;
  final List<CrewDto>? crew;

  CreditsResponse({
    required this.id,
    this.cast,
    this.crew,
  });

  factory CreditsResponse.fromJson(Map<String, dynamic> json) =>
      _$CreditsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreditsResponseToJson(this);
}

@JsonSerializable()
class CastDto {
  final int id;
  final String name;
  final String character;
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  @JsonKey(name: 'cast_id')
  final int? castId;
  final int? order;

  CastDto({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    this.castId,
    this.order,
  });

  factory CastDto.fromJson(Map<String, dynamic> json) =>
      _$CastDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CastDtoToJson(this);
}

@JsonSerializable()
class CrewDto {
  final int id;
  final String name;
  final String job;
  final String department;
  @JsonKey(name: 'profile_path')
  final String? profilePath;

  CrewDto({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });

  factory CrewDto.fromJson(Map<String, dynamic> json) =>
      _$CrewDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CrewDtoToJson(this);
}

@JsonSerializable()
class GenresResponse {
  final List<GenreDto>? genres;

  GenresResponse({
    this.genres,
  });

  factory GenresResponse.fromJson(Map<String, dynamic> json) =>
      _$GenresResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GenresResponseToJson(this);
}

@JsonSerializable()
class VideoDto {
  final String key;
  final String name;
  final String site;
  final String type;

  VideoDto({required this.key, required this.name, required this.site, required this.type});

  factory VideoDto.fromJson(Map<String, dynamic> json) => VideoDto(
    key: json['key'],
    name: json['name'],
    site: json['site'],
    type: json['type'],
  );
} 