import 'package:mivi/core/constants/api_constants.dart';
import 'package:mivi/data/models/api_models.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/services/api_service.dart';
import 'package:collection/collection.dart';

class MovieRepository {
  final ApiService _apiService;
  List<Genre> _allGenres = [];

  MovieRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<Genre> get allGenres => _allGenres;

  // Hàm lấy genres từ API và cache lại
  Future<void> fetchAndCacheGenres() async {
    _allGenres = await getGenres();
  }

  // Convert DTO to domain model
  Movie _convertMovieDtoToMovie(MovieDto dto, {bool isFavorite = false}) {
    // Map genre_ids sang Genre
    final movieGenres = dto.genreIds?.map((id) =>
      _allGenres.firstWhere((g) => g.id == id, orElse: () => Genre(id: id, name: 'Unknown'))
    ).toList() ?? [];

    return Movie(
      id: dto.id,
      title: dto.title,
      overview: dto.overview,
      posterPath: dto.posterPath != null 
          ? '${ApiConstants.imageBaseUrl}/${ApiConstants.posterSize}${dto.posterPath}'
          : 'https://via.placeholder.com/500x750',
      backdropPath: dto.backdropPath != null 
          ? '${ApiConstants.imageBaseUrl}/${ApiConstants.backdropSize}${dto.backdropPath}'
          : 'https://via.placeholder.com/1200x300',
      voteAverage: dto.voteAverage ?? 0.0,
      releaseDate: dto.releaseDate ?? 'Unknown',
      genres: movieGenres, // <-- gán đúng genre
      isFavorite: isFavorite,
    );
  }

  // Convert MovieDetailDto to Movie
  Movie _convertMovieDetailDtoToMovie(MovieDetailDto dto, {bool isFavorite = false}) {
    return Movie(
      id: dto.id,
      title: dto.title,
      overview: dto.overview,
      posterPath: dto.posterPath != null 
          ? '${ApiConstants.imageBaseUrl}/${ApiConstants.posterSize}${dto.posterPath}'
          : 'https://via.placeholder.com/500x750',
      backdropPath: dto.backdropPath != null 
          ? '${ApiConstants.imageBaseUrl}/${ApiConstants.backdropSize}${dto.backdropPath}'
          : 'https://via.placeholder.com/1200x300',
      voteAverage: dto.voteAverage ?? 0.0,
      releaseDate: dto.releaseDate ?? 'Unknown',
      genres: dto.genres?.map((g) => Genre(id: g.id, name: g.name)).toList() ?? [],
      isFavorite: isFavorite,
      runtime: dto.runtime ?? 0,
      tagline: dto.tagline,
      status: dto.status,
      originalLanguage: dto.originalLanguage,
      budget: dto.budget,
      revenue: dto.revenue,
    );
  }

  // Convert CastDto to CastMember
  CastMember _convertCastDtoToCastMember(CastDto dto) {
    return CastMember(
      id: dto.id,
      name: dto.name,
      character: dto.character,
      profilePath: dto.profilePath != null 
          ? '${ApiConstants.imageBaseUrl}/${ApiConstants.profileSize}${dto.profilePath}'
          : null,
    );
  }

  // Get trending movies
  Future<List<Movie>> getTrendingMovies({int page = 1}) async {
    try {
      final response = await _apiService.getTrendingMovies(page: page);
      print('Trending movies response: \\${response.results}');
      return response.results?.map((dto) => _convertMovieDtoToMovie(dto)).toList() ?? [];
    } catch (e) {
      print('Error fetching trending movies: \\${e}');
      throw Exception('Failed to fetch trending movies: $e');
    }
  }

  // Get popular movies
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _apiService.getPopularMovies(page: page);
      print('Popular movies response: \\${response.results}');
      return response.results?.map((dto) => _convertMovieDtoToMovie(dto)).toList() ?? [];
    } catch (e) {
      print('Error fetching popular movies: \\${e}');
      throw Exception('Failed to fetch popular movies: $e');
    }
  }

  // Get top rated movies
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await _apiService.getTopRatedMovies(page: page);
      print('Top rated movies response: \\${response.results}');
      return response.results?.map((dto) => _convertMovieDtoToMovie(dto)).toList() ?? [];
    } catch (e) {
      print('Error fetching top rated movies: \\${e}');
      throw Exception('Failed to fetch top rated movies: $e');
    }
  }

  // Get upcoming movies
  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    try {
      final response = await _apiService.getUpcomingMovies(page: page);
      return response.results?.map((dto) => _convertMovieDtoToMovie(dto)).toList() ?? [];
    } catch (e) {
      throw Exception('Failed to fetch upcoming movies: $e');
    }
  }

  // Get now playing movies
  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    try {
      final response = await _apiService.getNowPlayingMovies(page: page);
      print('Now playing movies response: \\${response.results}');
      return response.results?.map((dto) => _convertMovieDtoToMovie(dto)).toList() ?? [];
    } catch (e) {
      print('Error fetching now playing movies: \\${e}');
      throw Exception('Failed to fetch now playing movies: $e');
    }
  }

  // Get movie details
  Future<Movie> getMovieDetails(int movieId, {bool isFavorite = false}) async {
    try {
      final movieDetail = await _apiService.getMovieDetails(movieId);
      return _convertMovieDetailDtoToMovie(movieDetail, isFavorite: isFavorite);
    } catch (e) {
      throw Exception('Failed to fetch movie details: $e');
    }
  }

  // Get movie with credits
  Future<Movie> getMovieWithCredits(int movieId, {bool isFavorite = false}) async {
    try {
      final movieDetail = await _apiService.getMovieDetails(movieId);
      final credits = await _apiService.getMovieCredits(movieId);
      
      final movie = _convertMovieDetailDtoToMovie(movieDetail, isFavorite: isFavorite);
      final cast = credits.cast?.map((dto) => _convertCastDtoToCastMember(dto)).toList() ?? [];
      
      return movie.copyWith(cast: cast);
    } catch (e) {
      throw Exception('Failed to fetch movie with credits: $e');
    }
  }

  // Get similar movies
  Future<List<Movie>> getSimilarMovies(int movieId, {int page = 1}) async {
    try {
      final response = await _apiService.getSimilarMovies(movieId, page: page);
      return response.results?.map((dto) => _convertMovieDtoToMovie(dto)).toList() ?? [];
    } catch (e) {
      throw Exception('Failed to fetch similar movies: $e');
    }
  }

  // Search movies
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _apiService.searchMovies(query, page: page);
      return response.results?.map((dto) => _convertMovieDtoToMovie(dto)).toList() ?? [];
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  // Get genres
  Future<List<Genre>> getGenres() async {
    try {
      final response = await _apiService.getGenres();
      return response.genres?.map((dto) => Genre(id: dto.id, name: dto.name)).toList() ?? [];
    } catch (e) {
      throw Exception('Failed to fetch genres: $e');
    }
  }

  // Get YouTube trailer key with better selection logic
  Future<String?> getTrailerYoutubeKey(int movieId) async {
    try {
      final videos = await _apiService.getMovieVideos(movieId);
      
      // Ưu tiên trailer chính thức (Official Trailer)
      final officialTrailer = videos.firstWhereOrNull(
        (v) => v.site == 'YouTube' && 
               v.type == 'Trailer' && 
               v.name.toLowerCase().contains('official'),
      );
      
      if (officialTrailer != null) {
        return officialTrailer.key;
      }
      
      // Nếu không có trailer chính thức, lấy trailer đầu tiên
      final trailer = videos.firstWhereOrNull(
        (v) => v.site == 'YouTube' && v.type == 'Trailer',
      );
      
      if (trailer != null) {
        return trailer.key;
      }
      
      // Nếu không có trailer, lấy video đầu tiên từ YouTube
      final youtubeVideo = videos.firstWhereOrNull(
        (v) => v.site == 'YouTube',
      );
      
      return youtubeVideo?.key;
    } catch (e) {
      print('Error getting trailer for movie $movieId: $e');
      return null;
    }
  }

  // Get all videos for a movie (including trailers, teasers, etc.)
  Future<List<VideoDto>> getMovieVideos(int movieId) async {
    try {
      return await _apiService.getMovieVideos(movieId);
    } catch (e) {
      print('Error getting videos for movie $movieId: $e');
      return [];
    }
  }

  // Get movies by genre
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final response = await _apiService.getMoviesByGenre(genreId, page: page);
      return response.results?.map((dto) => _convertMovieDtoToMovie(dto)).toList() ?? [];
    } catch (e) {
      throw Exception('Failed to fetch movies by genre: $e');
    }
  }
} 