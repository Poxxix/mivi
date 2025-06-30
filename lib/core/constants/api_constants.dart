class ApiConstants {
  // TMDB API Configuration
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String apiKey = '8ea3043f7092f543784cac4fa420a887';
  static const String apiReadAccessToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4ZWEzMDQzZjcwOTJmNTQzNzg0Y2FjNGZhNDIwYTg4NyIsIm5iZiI6MTc0NzkxOTI0My4zLCJzdWIiOiI2ODJmMjE4YjEzODIwYWNlNDUxYzFmNTAiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0._Ky3qczRqJ1SRKiicnjAmCafcpUdY6Z9VORZCA852Yg';
  
  // Image sizes
  static const String posterSize = 'w500';
  static const String backdropSize = 'original';
  static const String profileSize = 'w185';
  
  // Endpoints
  static const String trendingMovies = '/trending/movie/week';
  static const String popularMovies = '/movie/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String upcomingMovies = '/movie/upcoming';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String movieDetails = '/movie/{movie_id}';
  static const String movieCredits = '/movie/{movie_id}/credits';
  static const String similarMovies = '/movie/{movie_id}/similar';
  static const String searchMovies = '/search/movie';
  static const String genres = '/genre/movie/list';
  
  // Query parameters
  static const String apiKeyParam = 'api_key';
  static const String languageParam = 'language';
  static const String pageParam = 'page';
  static const String queryParam = 'query';
  
  // Default values
  static const String defaultLanguage = 'en-US';
  static const int defaultPage = 1;
} 