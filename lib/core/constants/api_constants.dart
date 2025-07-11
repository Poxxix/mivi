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

  // Soundtrack API endpoints
  static const String movieThemeApiBase = 'http://localhost:5000/api/v1'; // Local Movie Theme Song Database
  static const String theAudioDbBase = 'https://www.theaudiodb.com/api/v1/json/1';
  static const String musicBrainzBase = 'https://musicbrainz.org/ws/2';
  
  // Music platform search URLs
  static const String spotifySearchBase = 'https://open.spotify.com/search';
  static const String youtubeSearchBase = 'https://www.youtube.com/results';
  static const String appleMusicSearchBase = 'https://music.apple.com/search';
  
  // TheAudioDB API key (free tier)
  static const String theAudioDbApiKey = '1'; // Free public key
  
  // MusicBrainz user agent (required)
  static const String musicBrainzUserAgent = 'Mivi/1.0 (contact@mivi.app)';
  
  // API timeouts
  static const int apiTimeoutSeconds = 10;
  static const int retryAttempts = 3;
  
  // Soundtrack API endpoints
  static String getMovieThemeApiUrl(int movieId) => '$movieThemeApiBase/movies/$movieId';
  static String getTheAudioDbSearchUrl(String query) => '$theAudioDbBase/searchalbum.php?s=${Uri.encodeComponent(query)}';
  static String getMusicBrainzSearchUrl(String query) => '$musicBrainzBase/release-group?query=${Uri.encodeComponent(query)}&fmt=json&limit=5';
  
  // Search URL generators
  static String generateSpotifySearchUrl(String movieTitle, String trackTitle) {
    final query = Uri.encodeComponent('$movieTitle $trackTitle soundtrack');
    return '$spotifySearchBase?q=$query';
  }
  
  static String generateYouTubeSearchUrl(String movieTitle, String trackTitle) {
    final query = Uri.encodeComponent('$movieTitle $trackTitle soundtrack');
    return '$youtubeSearchBase?search_query=$query';
  }
  
  static String generateAppleMusicSearchUrl(String movieTitle, String trackTitle) {
    final query = Uri.encodeComponent('$movieTitle $trackTitle soundtrack');
    return '$appleMusicSearchBase?term=$query';
  }
} 