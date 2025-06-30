// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieResponse _$MovieResponseFromJson(Map<String, dynamic> json) =>
    MovieResponse(
      page: (json['page'] as num?)?.toInt(),
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => MovieDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      totalResults: (json['totalResults'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MovieResponseToJson(MovieResponse instance) =>
    <String, dynamic>{
      'page': instance.page,
      'results': instance.results,
      'totalPages': instance.totalPages,
      'totalResults': instance.totalResults,
    };

MovieDto _$MovieDtoFromJson(Map<String, dynamic> json) => MovieDto(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  overview: json['overview'] as String,
  posterPath: json['poster_path'] as String?,
  backdropPath: json['backdrop_path'] as String?,
  voteAverage: (json['vote_average'] as num?)?.toDouble(),
  releaseDate: json['release_date'] as String?,
  genreIds: (json['genre_ids'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  adult: json['adult'] as bool?,
  originalLanguage: json['original_language'] as String?,
  originalTitle: json['original_title'] as String?,
  popularity: (json['popularity'] as num?)?.toDouble(),
  voteCount: (json['vote_count'] as num?)?.toInt(),
  video: json['video'] as bool?,
);

Map<String, dynamic> _$MovieDtoToJson(MovieDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'overview': instance.overview,
  'poster_path': instance.posterPath,
  'backdrop_path': instance.backdropPath,
  'vote_average': instance.voteAverage,
  'release_date': instance.releaseDate,
  'genre_ids': instance.genreIds,
  'adult': instance.adult,
  'original_language': instance.originalLanguage,
  'original_title': instance.originalTitle,
  'popularity': instance.popularity,
  'vote_count': instance.voteCount,
  'video': instance.video,
};

MovieDetailDto _$MovieDetailDtoFromJson(Map<String, dynamic> json) =>
    MovieDetailDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      releaseDate: json['release_date'] as String?,
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => GenreDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      adult: json['adult'] as bool?,
      originalLanguage: json['original_language'] as String?,
      originalTitle: json['original_title'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      voteCount: (json['vote_count'] as num?)?.toInt(),
      runtime: (json['runtime'] as num?)?.toInt(),
      tagline: json['tagline'] as String?,
      status: json['status'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      revenue: (json['revenue'] as num?)?.toDouble(),
      productionCompanies: (json['production_companies'] as List<dynamic>?)
          ?.map((e) => ProductionCompanyDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MovieDetailDtoToJson(MovieDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'vote_average': instance.voteAverage,
      'release_date': instance.releaseDate,
      'genres': instance.genres,
      'adult': instance.adult,
      'original_language': instance.originalLanguage,
      'original_title': instance.originalTitle,
      'popularity': instance.popularity,
      'vote_count': instance.voteCount,
      'runtime': instance.runtime,
      'tagline': instance.tagline,
      'status': instance.status,
      'budget': instance.budget,
      'revenue': instance.revenue,
      'production_companies': instance.productionCompanies,
    };

GenreDto _$GenreDtoFromJson(Map<String, dynamic> json) =>
    GenreDto(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$GenreDtoToJson(GenreDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

ProductionCompanyDto _$ProductionCompanyDtoFromJson(
  Map<String, dynamic> json,
) => ProductionCompanyDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  logoPath: json['logo_path'] as String?,
  originCountry: json['origin_country'] as String?,
);

Map<String, dynamic> _$ProductionCompanyDtoToJson(
  ProductionCompanyDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'logo_path': instance.logoPath,
  'origin_country': instance.originCountry,
};

CreditsResponse _$CreditsResponseFromJson(Map<String, dynamic> json) =>
    CreditsResponse(
      id: (json['id'] as num).toInt(),
      cast: (json['cast'] as List<dynamic>?)
          ?.map((e) => CastDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      crew: (json['crew'] as List<dynamic>?)
          ?.map((e) => CrewDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreditsResponseToJson(CreditsResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cast': instance.cast,
      'crew': instance.crew,
    };

CastDto _$CastDtoFromJson(Map<String, dynamic> json) => CastDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  character: json['character'] as String,
  profilePath: json['profile_path'] as String?,
  castId: (json['cast_id'] as num?)?.toInt(),
  order: (json['order'] as num?)?.toInt(),
);

Map<String, dynamic> _$CastDtoToJson(CastDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'character': instance.character,
  'profile_path': instance.profilePath,
  'cast_id': instance.castId,
  'order': instance.order,
};

CrewDto _$CrewDtoFromJson(Map<String, dynamic> json) => CrewDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  job: json['job'] as String,
  department: json['department'] as String,
  profilePath: json['profile_path'] as String?,
);

Map<String, dynamic> _$CrewDtoToJson(CrewDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'job': instance.job,
  'department': instance.department,
  'profile_path': instance.profilePath,
};

GenresResponse _$GenresResponseFromJson(Map<String, dynamic> json) =>
    GenresResponse(
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => GenreDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GenresResponseToJson(GenresResponse instance) =>
    <String, dynamic>{'genres': instance.genres};
