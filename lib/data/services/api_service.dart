import 'package:dio/dio.dart';
import 'package:mivi/core/constants/api_constants.dart';
import 'package:mivi/data/models/api_models.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      queryParameters: {
        ApiConstants.apiKeyParam: ApiConstants.apiKey,
        ApiConstants.languageParam: ApiConstants.defaultLanguage,
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  // Get trending movies
  Future<MovieResponse> getTrendingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.trendingMovies,
        queryParameters: {ApiConstants.pageParam: page},
      );
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get popular movies
  Future<MovieResponse> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.popularMovies,
        queryParameters: {ApiConstants.pageParam: page},
      );
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get top rated movies
  Future<MovieResponse> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.topRatedMovies,
        queryParameters: {ApiConstants.pageParam: page},
      );
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get upcoming movies
  Future<MovieResponse> getUpcomingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.upcomingMovies,
        queryParameters: {ApiConstants.pageParam: page},
      );
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get now playing movies
  Future<MovieResponse> getNowPlayingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.nowPlayingMovies,
        queryParameters: {ApiConstants.pageParam: page},
      );
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get movie details
  Future<MovieDetailDto> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        ApiConstants.movieDetails.replaceAll('{movie_id}', movieId.toString()),
      );
      return MovieDetailDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get movie credits
  Future<CreditsResponse> getMovieCredits(int movieId) async {
    try {
      final response = await _dio.get(
        ApiConstants.movieCredits.replaceAll('{movie_id}', movieId.toString()),
      );
      return CreditsResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get similar movies
  Future<MovieResponse> getSimilarMovies(int movieId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.similarMovies.replaceAll('{movie_id}', movieId.toString()),
        queryParameters: {ApiConstants.pageParam: page},
      );
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Search movies
  Future<MovieResponse> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchMovies,
        queryParameters: {
          ApiConstants.queryParam: query,
          ApiConstants.pageParam: page,
        },
      );
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get genres
  Future<GenresResponse> getGenres() async {
    try {
      final response = await _dio.get(ApiConstants.genres);
      return GenresResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get movie videos (trailers)
  Future<List<VideoDto>> getMovieVideos(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId/videos');
      return (response.data['results'] as List)
          .map((json) => VideoDto.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get movies by genre
  Future<MovieResponse> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          ApiConstants.pageParam: page,
          'with_genres': genreId.toString(),
        },
      );
      return MovieResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['status_message'] ?? 'Unknown error occurred';
          return Exception('HTTP $statusCode: $message');
        case DioExceptionType.cancel:
          return Exception('Request was cancelled');
        case DioExceptionType.connectionError:
          return Exception('No internet connection');
        default:
          return Exception('An unexpected error occurred');
      }
    }
    return Exception('An unexpected error occurred: $error');
  }
} 