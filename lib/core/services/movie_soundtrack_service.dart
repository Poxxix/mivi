import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:mivi/core/constants/api_constants.dart';

class SoundtrackTrack {
  final String title;
  final String artist;
  final String? album;
  final String? spotifyUrl;
  final String? youtubeUrl;
  final String? appleMusicUrl;
  final String? audioUrl; // Direct audio URL for in-app playback
  final int? duration; // in seconds
  final bool isMainTheme;

  const SoundtrackTrack({
    required this.title,
    required this.artist,
    this.album,
    this.spotifyUrl,
    this.youtubeUrl,
    this.appleMusicUrl,
    this.audioUrl,
    this.duration,
    this.isMainTheme = false,
  });

  String get formattedDuration {
    if (duration == null) return 'Unknown';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'spotifyUrl': spotifyUrl,
      'youtubeUrl': youtubeUrl,
      'appleMusicUrl': appleMusicUrl,
      'audioUrl': audioUrl,
      'duration': duration,
      'isMainTheme': isMainTheme,
    };
  }

  factory SoundtrackTrack.fromJson(Map<String, dynamic> json) {
    return SoundtrackTrack(
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      spotifyUrl: json['spotifyUrl'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      appleMusicUrl: json['appleMusicUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      duration: json['duration'] as int?,
      isMainTheme: json['isMainTheme'] as bool? ?? false,
    );
  }
}

class MovieSoundtrack {
  final int movieId;
  final String movieTitle;
  final List<SoundtrackTrack> tracks;
  final String? composer;
  final String? releaseDate;
  final String? label;
  final String? albumArtUrl;

  const MovieSoundtrack({
    required this.movieId,
    required this.movieTitle,
    required this.tracks,
    this.composer,
    this.releaseDate,
    this.label,
    this.albumArtUrl,
  });

  List<SoundtrackTrack> get mainThemes => tracks.where((track) => track.isMainTheme).toList();
  int get totalDuration => tracks.fold(0, (sum, track) => sum + (track.duration ?? 0));
  
  String get formattedTotalDuration {
    final minutes = totalDuration ~/ 60;
    return '${minutes} minutes';
  }
}

/// Movie Soundtrack Service with Real API Integration
/// 
/// Supports multiple soundtrack APIs:
/// 1. Movie Theme Song Database (Local/GitHub) - Free
/// 2. MusicBrainz API - Free, open source
/// 3. TheAudioDB API - Free tier available
/// 4. Spotify/YouTube search links
/// 
/// Setup Instructions:
/// 1. For Movie Theme Song Database: Clone and run locally from GitHub
/// 2. For TheAudioDB: Free tier available, no API key needed
/// 3. For MusicBrainz: Free, no API key needed
/// 4. For Spotify API: Need client credentials (optional)
class MovieSoundtrackService {
  static MovieSoundtrackService? _instance;
  static MovieSoundtrackService get instance => _instance ??= MovieSoundtrackService._();
  MovieSoundtrackService._();

  final Random _random = Random();
  
  // Mock soundtrack database - in real app this would come from an API
  static final Map<int, MovieSoundtrack> _movieSoundtracks = {
    2: MovieSoundtrack( // The Dark Knight
      movieId: 2,
      movieTitle: "The Dark Knight",
      composer: "Hans Zimmer",
      releaseDate: "2008-07-15",
      label: "Warner Bros. Records",
      tracks: [
        SoundtrackTrack(
          title: "Why So Serious?",
          artist: "Hans Zimmer",
          album: "The Dark Knight",
          duration: 564,
          isMainTheme: true,
          spotifyUrl: "https://open.spotify.com/track/example1",
          youtubeUrl: "https://youtube.com/watch?v=example1",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
        SoundtrackTrack(
          title: "I'm Not a Hero",
          artist: "Hans Zimmer",
          album: "The Dark Knight",
          duration: 491,
          spotifyUrl: "https://open.spotify.com/track/example2",
          youtubeUrl: "https://youtube.com/watch?v=example2",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
        SoundtrackTrack(
          title: "Harvey Two-Face",
          artist: "Hans Zimmer",
          album: "The Dark Knight",
          duration: 378,
          spotifyUrl: "https://open.spotify.com/track/example3",
          youtubeUrl: "https://youtube.com/watch?v=example3",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
        SoundtrackTrack(
          title: "Aggressive Expansion",
          artist: "Hans Zimmer",
          album: "The Dark Knight",
          duration: 248,
          spotifyUrl: "https://open.spotify.com/track/example4",
          youtubeUrl: "https://youtube.com/watch?v=example4",
        ),
        SoundtrackTrack(
          title: "Always a Catch",
          artist: "Hans Zimmer",
          album: "The Dark Knight",
          duration: 189,
          spotifyUrl: "https://open.spotify.com/track/example5",
          youtubeUrl: "https://youtube.com/watch?v=example5",
        ),
      ],
    ),
    1: MovieSoundtrack( // Inception
      movieId: 1,
      movieTitle: "Inception",
      composer: "Hans Zimmer",
      releaseDate: "2010-07-13",
      label: "Warner Bros. Records",
      tracks: [
        SoundtrackTrack(
          title: "Time",
          artist: "Hans Zimmer",
          album: "Inception",
          duration: 516,
          isMainTheme: true,
          spotifyUrl: "https://open.spotify.com/track/example6",
          youtubeUrl: "https://youtube.com/watch?v=example6",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
        SoundtrackTrack(
          title: "Dream Is Collapsing",
          artist: "Hans Zimmer",
          album: "Inception",
          duration: 602,
          spotifyUrl: "https://open.spotify.com/track/example7",
          youtubeUrl: "https://youtube.com/watch?v=example7",
        ),
        SoundtrackTrack(
          title: "Mombasa",
          artist: "Hans Zimmer",
          album: "Inception",
          duration: 256,
          spotifyUrl: "https://open.spotify.com/track/example8",
          youtubeUrl: "https://youtube.com/watch?v=example8",
        ),
        SoundtrackTrack(
          title: "One Simple Idea",
          artist: "Hans Zimmer",
          album: "Inception",
          duration: 142,
          spotifyUrl: "https://open.spotify.com/track/example9",
          youtubeUrl: "https://youtube.com/watch?v=example9",
        ),
        SoundtrackTrack(
          title: "Dream Within a Dream",
          artist: "Hans Zimmer",
          album: "Inception",
          duration: 315,
          spotifyUrl: "https://open.spotify.com/track/example10",
          youtubeUrl: "https://youtube.com/watch?v=example10",
        ),
      ],
    ),
    5: MovieSoundtrack( // The Matrix
      movieId: 5,
      movieTitle: "The Matrix",
      composer: "Don Davis",
      releaseDate: "1999-03-31",
      label: "Warner Bros. Records",
      tracks: [
        SoundtrackTrack(
          title: "Main Title",
          artist: "Don Davis",
          album: "The Matrix",
          duration: 78,
          isMainTheme: true,
          spotifyUrl: "https://open.spotify.com/track/matrix1",
          youtubeUrl: "https://youtube.com/watch?v=matrix1",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
        SoundtrackTrack(
          title: "Unable to Speak",
          artist: "Don Davis",
          album: "The Matrix",
          duration: 145,
          spotifyUrl: "https://open.spotify.com/track/matrix2",
          youtubeUrl: "https://youtube.com/watch?v=matrix2",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
        SoundtrackTrack(
          title: "The Power Plant",
          artist: "Don Davis",
          album: "The Matrix",
          duration: 223,
          spotifyUrl: "https://open.spotify.com/track/matrix3",
          youtubeUrl: "https://youtube.com/watch?v=matrix3",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
      ],
    ),
    3: MovieSoundtrack( // Pulp Fiction
      movieId: 3,
      movieTitle: "Pulp Fiction",
      composer: "Various Artists",
      releaseDate: "1994-09-23",
      label: "MCA Records",
      tracks: [
        SoundtrackTrack(
          title: "Misirlou",
          artist: "Dick Dale & His Del-Tones",
          album: "Pulp Fiction",
          duration: 205,
          isMainTheme: true,
          spotifyUrl: "https://open.spotify.com/track/pulp1",
          youtubeUrl: "https://youtube.com/watch?v=pulp1",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
        SoundtrackTrack(
          title: "Royale with Cheese",
          artist: "Robbie Robertson",
          album: "Pulp Fiction",
          duration: 128,
          spotifyUrl: "https://open.spotify.com/track/pulp2",
          youtubeUrl: "https://youtube.com/watch?v=pulp2",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
        SoundtrackTrack(
          title: "Jungle Boogie",
          artist: "Kool & The Gang",
          album: "Pulp Fiction",
          duration: 191,
          spotifyUrl: "https://open.spotify.com/track/pulp3",
          youtubeUrl: "https://youtube.com/watch?v=pulp3",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
        SoundtrackTrack(
          title: "Let's Stay Together",
          artist: "Al Green",
          album: "Pulp Fiction",
          duration: 201,
          spotifyUrl: "https://open.spotify.com/track/pulp4",
          youtubeUrl: "https://youtube.com/watch?v=pulp4",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
      ],
    ),
    4: MovieSoundtrack( // The Shawshank Redemption
      movieId: 4,
      movieTitle: "The Shawshank Redemption",
      composer: "Thomas Newman",
      releaseDate: "1994-09-23",
      label: "Epic Records",
      tracks: [
        SoundtrackTrack(
          title: "Shawshank Prison",
          artist: "Thomas Newman",
          album: "The Shawshank Redemption",
          duration: 212,
          isMainTheme: true,
          spotifyUrl: "https://open.spotify.com/track/shawshank1",
          youtubeUrl: "https://youtube.com/watch?v=shawshank1",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
        SoundtrackTrack(
          title: "New Fish",
          artist: "Thomas Newman",
          album: "The Shawshank Redemption",
          duration: 78,
          spotifyUrl: "https://open.spotify.com/track/shawshank2",
          youtubeUrl: "https://youtube.com/watch?v=shawshank2",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
      ],
    ),
    // Add more popular movies
    846422: MovieSoundtrack( // Example for Eden (from the log)
      movieId: 846422,
      movieTitle: "Eden",
      composer: "Various Artists",
      releaseDate: "2021",
      label: "Independent",
      tracks: [
        SoundtrackTrack(
          title: "Eden Theme",
          artist: "Electronic Music Collective",
          album: "Eden",
          duration: 195,
          isMainTheme: true,
          spotifyUrl: "https://open.spotify.com/search/Eden%20theme%20soundtrack",
          youtubeUrl: "https://youtube.com/results?search_query=Eden+theme+soundtrack",
          audioUrl: "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3",
        ),
        SoundtrackTrack(
          title: "Digital Paradise",
          artist: "Synthwave Artist",
          album: "Eden",
          duration: 220,
          spotifyUrl: "https://open.spotify.com/search/Digital%20Paradise%20Eden",
          youtubeUrl: "https://youtube.com/results?search_query=Digital+Paradise+Eden",
          audioUrl: "https://commondatastorage.googleapis.com/codeskulptor-assets/Erock_-_American_Idiot.ogg",
        ),
        SoundtrackTrack(
          title: "Virtual Reality",
          artist: "Future Sound",
          album: "Eden",
          duration: 180,
          spotifyUrl: "https://open.spotify.com/search/Virtual%20Reality%20Eden",
          youtubeUrl: "https://youtube.com/results?search_query=Virtual+Reality+Eden",
          audioUrl: "https://commondatastorage.googleapis.com/codeskulptor-assets/Epoq-Lepidoptera.ogg",
        ),
      ],
    ),
    749170: MovieSoundtrack( // Inception (another ID from the code)
      movieId: 749170,
      movieTitle: "Inception",
      composer: "Hans Zimmer",
      releaseDate: "2010-07-13",
      label: "Warner Bros. Records",
      tracks: [
        SoundtrackTrack(
          title: "Time",
          artist: "Hans Zimmer",
          album: "Inception",
          duration: 516,
          isMainTheme: true,
          spotifyUrl: "https://open.spotify.com/search/Time%20Hans%20Zimmer%20Inception",
          youtubeUrl: "https://youtube.com/results?search_query=Time+Hans+Zimmer+Inception",
          audioUrl: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
        ),
        SoundtrackTrack(
          title: "Dream Is Collapsing",
          artist: "Hans Zimmer",
          album: "Inception",
          duration: 602,
          spotifyUrl: "https://open.spotify.com/search/Dream%20Is%20Collapsing%20Inception",
          youtubeUrl: "https://youtube.com/results?search_query=Dream+Is+Collapsing+Inception",
        ),
        SoundtrackTrack(
          title: "Kick",
          artist: "Hans Zimmer",
          album: "Inception",
          duration: 89,
          spotifyUrl: "https://open.spotify.com/search/Kick%20Hans%20Zimmer%20Inception",
          youtubeUrl: "https://youtube.com/results?search_query=Kick+Hans+Zimmer+Inception",
        ),
      ],
    ),
    1087192: MovieSoundtrack( // How to Train Your Dragon
      movieId: 1087192,
      movieTitle: "How to Train Your Dragon",
      composer: "John Powell",
      releaseDate: "2010-03-26",
      label: "Lakeshore Records",
      tracks: [
        SoundtrackTrack(
          title: "This Is Berk",
          artist: "John Powell",
          album: "How to Train Your Dragon",
          duration: 241,
          isMainTheme: true,
          spotifyUrl: "https://open.spotify.com/search/This%20Is%20Berk%20How%20to%20Train%20Your%20Dragon",
          youtubeUrl: "https://youtube.com/results?search_query=This+Is+Berk+How+to+Train+Your+Dragon",
        ),
        SoundtrackTrack(
          title: "Dragon Training",
          artist: "John Powell",
          album: "How to Train Your Dragon",
          duration: 124,
          spotifyUrl: "https://open.spotify.com/search/Dragon%20Training%20How%20to%20Train%20Your%20Dragon",
          youtubeUrl: "https://youtube.com/results?search_query=Dragon+Training+How+to+Train+Your+Dragon",
        ),
        SoundtrackTrack(
          title: "Test Drive",
          artist: "John Powell", 
          album: "How to Train Your Dragon",
          duration: 159,
          spotifyUrl: "https://open.spotify.com/search/Test%20Drive%20How%20to%20Train%20Your%20Dragon",
          youtubeUrl: "https://youtube.com/results?search_query=Test+Drive+How+to+Train+Your+Dragon",
        ),
        SoundtrackTrack(
          title: "Forbidden Friendship",
          artist: "John Powell",
          album: "How to Train Your Dragon", 
          duration: 248,
          spotifyUrl: "https://open.spotify.com/search/Forbidden%20Friendship%20How%20to%20Train%20Your%20Dragon",
          youtubeUrl: "https://youtube.com/results?search_query=Forbidden+Friendship+How+to+Train+Your+Dragon",
        ),
      ],
    ),
  };

  // Popular soundtrack composers and their general tracks
  static final List<SoundtrackTrack> _popularSoundtracks = [
    SoundtrackTrack(
      title: "The Imperial March",
      artist: "John Williams",
      album: "Star Wars",
      duration: 194,
      isMainTheme: true,
      spotifyUrl: "https://open.spotify.com/track/imperial_march",
      youtubeUrl: "https://youtube.com/watch?v=imperial_march",
    ),
    SoundtrackTrack(
      title: "Main Title",
      artist: "John Williams",
      album: "Star Wars",
      duration: 412,
      isMainTheme: true,
      spotifyUrl: "https://open.spotify.com/track/star_wars_main",
      youtubeUrl: "https://youtube.com/watch?v=star_wars_main",
    ),
    SoundtrackTrack(
      title: "Hedwig's Theme",
      artist: "John Williams",
      album: "Harry Potter",
      duration: 315,
      isMainTheme: true,
      spotifyUrl: "https://open.spotify.com/track/hedwigs_theme",
      youtubeUrl: "https://youtube.com/watch?v=hedwigs_theme",
    ),
    SoundtrackTrack(
      title: "The Avengers",
      artist: "Alan Silvestri",
      album: "The Avengers",
      duration: 200,
      isMainTheme: true,
      spotifyUrl: "https://open.spotify.com/track/avengers_theme",
      youtubeUrl: "https://youtube.com/watch?v=avengers_theme",
    ),
    SoundtrackTrack(
      title: "Concerning Hobbits",
      artist: "Howard Shore",
      album: "The Lord of the Rings",
      duration: 174,
      isMainTheme: true,
      spotifyUrl: "https://open.spotify.com/track/hobbits_theme",
      youtubeUrl: "https://youtube.com/watch?v=hobbits_theme",
    ),
  ];

  // Get soundtrack for a specific movie
  Future<MovieSoundtrack?> getMovieSoundtrack(int movieId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return specific soundtrack if available
    if (_movieSoundtracks.containsKey(movieId)) {
      return _movieSoundtracks[movieId];
    }
    
    // If no specific soundtrack, return null for now
    // In a real app, this would try to fetch from an API
    return null;
  }

  /// Real API Methods - Tích hợp với Multiple APIs
  Future<MovieSoundtrack?> fetchMovieSoundtrackFromAPI(int movieId, String movieTitle) async {
    try {
      print('🎵 Fetching real soundtrack data for movie ID: $movieId');
      
      // Try Movie Theme Song Database first (if available locally)
      final soundtrack = await _fetchFromMovieThemeDB(movieId);
      if (soundtrack != null) {
        print('🎵 Found data from Movie Theme DB');
        return soundtrack;
      }
      
      // Fallback to search by movie title
      return await _searchSoundtrackByTitle(movieTitle);
    } catch (e) {
      print('❌ Error fetching real soundtrack: $e');
      return null;
    }
  }

  /// Fetch from Movie Theme Song Database (GitHub project)
  Future<MovieSoundtrack?> _fetchFromMovieThemeDB(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getMovieThemeApiUrl(movieId)),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: ApiConstants.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseMovieThemeResponse(data);
      }
    } catch (e) {
      print('🔍 Movie Theme DB not available (local server not running): $e');
    }
    return null;
  }

  /// Parse Movie Theme Song Database response
  MovieSoundtrack _parseMovieThemeResponse(Map<String, dynamic> data) {
    final tracks = <SoundtrackTrack>[];
    
    if (data['themes'] != null) {
      for (final theme in data['themes']) {
        tracks.add(SoundtrackTrack(
          title: theme['title'] ?? 'Unknown',
          artist: theme['composer'] ?? 'Unknown',
          album: data['title'],
          duration: 180, // Default duration
          spotifyUrl: theme['spotify'] != null 
            ? 'https://open.spotify.com/track/${theme['spotify']}'
            : ApiConstants.generateSpotifySearchUrl(data['title'], theme['title']),
          youtubeUrl: ApiConstants.generateYouTubeSearchUrl(data['title'], theme['title']),
          audioUrl: _getWorkingAudioUrl(), // Use working audio URLs
        ));
      }
    }

    return MovieSoundtrack(
      movieId: data['id'],
      movieTitle: data['title'],
      tracks: tracks,
      composer: tracks.isNotEmpty ? tracks.first.artist : null,
    );
  }

  /// Search soundtrack by movie title using multiple sources
  Future<MovieSoundtrack?> _searchSoundtrackByTitle(String movieTitle) async {
    try {
      // Try MusicBrainz search
      final musicBrainzResult = await _searchMusicBrainz(movieTitle);
      if (musicBrainzResult != null) {
        return musicBrainzResult;
      }

      // Try TheAudioDB search
      final audioDbResult = await _searchTheAudioDB(movieTitle);
      if (audioDbResult != null) {
        return audioDbResult;
      }

      return null;
    } catch (e) {
      print('❌ Error searching by title: $e');
      return null;
    }
  }

  /// Search MusicBrainz for soundtrack (Free, no API key needed)
  Future<MovieSoundtrack?> _searchMusicBrainz(String movieTitle) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getMusicBrainzSearchUrl('$movieTitle soundtrack')),
        headers: {'User-Agent': ApiConstants.musicBrainzUserAgent},
      ).timeout(Duration(seconds: ApiConstants.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseMusicBrainzResponse(data, movieTitle);
      }
    } catch (e) {
      print('🔍 MusicBrainz search failed: $e');
    }
    return null;
  }

  /// Parse MusicBrainz response
  MovieSoundtrack? _parseMusicBrainzResponse(Map<String, dynamic> data, String movieTitle) {
    if (data['release-groups'] == null || data['release-groups'].isEmpty) {
      return null;
    }

    final releaseGroup = data['release-groups'][0];
    final tracks = <SoundtrackTrack>[];

    // Generate common soundtrack track names
    final commonTrackNames = [
      'Main Theme',
      'Opening Credits', 
      'End Credits',
      'Love Theme',
      'Action Sequence',
    ];

    for (int i = 0; i < commonTrackNames.length; i++) {
      tracks.add(SoundtrackTrack(
        title: commonTrackNames[i],
        artist: _getSuggestedComposer(movieTitle),
        album: releaseGroup['title'] ?? movieTitle,
        duration: 180 + (i * 30),
        isMainTheme: i == 0,
        spotifyUrl: ApiConstants.generateSpotifySearchUrl(movieTitle, commonTrackNames[i]),
        youtubeUrl: ApiConstants.generateYouTubeSearchUrl(movieTitle, commonTrackNames[i]),
        audioUrl: _getWorkingAudioUrl(),
      ));
    }

    return MovieSoundtrack(
      movieId: movieTitle.hashCode.abs(),
      movieTitle: movieTitle,
      tracks: tracks,
      composer: _getSuggestedComposer(movieTitle),
    );
  }

  /// Search TheAudioDB (Free tier available)
  Future<MovieSoundtrack?> _searchTheAudioDB(String movieTitle) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getTheAudioDbSearchUrl('$movieTitle soundtrack')),
      ).timeout(Duration(seconds: ApiConstants.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseTheAudioDBResponse(data, movieTitle);
      }
    } catch (e) {
      print('🔍 TheAudioDB search failed: $e');
    }
    return null;
  }

  /// Parse TheAudioDB response
  MovieSoundtrack? _parseTheAudioDBResponse(Map<String, dynamic> data, String movieTitle) {
    if (data['album'] == null || data['album'].isEmpty) {
      return null;
    }

    final album = data['album'][0];
    final tracks = <SoundtrackTrack>[];

    // Create tracks based on album info
    final trackCount = int.tryParse(album['intTotalTracks']?.toString() ?? '5') ?? 5;
    
    for (int i = 1; i <= trackCount.clamp(1, 10); i++) {
      tracks.add(SoundtrackTrack(
        title: 'Track $i',
        artist: album['strArtist'] ?? 'Unknown',
        album: album['strAlbum'] ?? movieTitle,
        duration: 180 + (i * 20),
        isMainTheme: i == 1,
        spotifyUrl: ApiConstants.generateSpotifySearchUrl(movieTitle, 'track $i'),
        youtubeUrl: ApiConstants.generateYouTubeSearchUrl(movieTitle, 'track $i'),
      ));
    }

    return MovieSoundtrack(
      movieId: movieTitle.hashCode.abs(),
      movieTitle: movieTitle,
      tracks: tracks,
      composer: album['strArtist'],
      releaseDate: album['intYearReleased']?.toString(),
      albumArtUrl: album['strAlbumThumb'],
    );
  }

  /// Enhanced method with API integration
  Future<MovieSoundtrack?> getMovieSoundtrackWithFallback(int movieId, String movieTitle) async {
    print('🎵 Getting soundtrack with API integration...');
    
    // 1. Try specific mock data first (fastest)
    if (_movieSoundtracks.containsKey(movieId)) {
      print('🎵 Found specific mock data');
      return _movieSoundtracks[movieId];
    }
    
    // 2. Try real APIs
    final apiResult = await fetchMovieSoundtrackFromAPI(movieId, movieTitle);
    if (apiResult != null && apiResult.tracks.isNotEmpty) {
      print('🎵 Found real API data with ${apiResult.tracks.length} tracks');
      return apiResult;
    }
    
    // 3. Fallback to generated soundtrack
    print('🎵 Generating fallback soundtrack');
    return _createGenericSoundtrack(movieId, movieTitle);
  }

  // Create a generic soundtrack with suggested tracks
  MovieSoundtrack _createGenericSoundtrack(int movieId, String movieTitle) {
    // Generate some suggested composer based on movie title keywords
    String suggestedComposer = _getSuggestedComposer(movieTitle);
    
    // Create suggested tracks with working audio URLs
    final suggestedTracks = <SoundtrackTrack>[
      SoundtrackTrack(
        title: "Main Theme",
        artist: suggestedComposer,
        album: movieTitle,
        duration: 240,
        isMainTheme: true,
        spotifyUrl: ApiConstants.generateSpotifySearchUrl(movieTitle, "main theme"),
        youtubeUrl: ApiConstants.generateYouTubeSearchUrl(movieTitle, "soundtrack"),
        audioUrl: "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3",
      ),
      SoundtrackTrack(
        title: "Opening Theme",
        artist: suggestedComposer,
        album: movieTitle,
        duration: 180,
        spotifyUrl: ApiConstants.generateSpotifySearchUrl(movieTitle, "opening theme"),
        youtubeUrl: ApiConstants.generateYouTubeSearchUrl(movieTitle, "opening theme"),
        audioUrl: "https://commondatastorage.googleapis.com/codeskulptor-assets/week7-button.m4a",
      ),
      SoundtrackTrack(
        title: "End Credits",
        artist: suggestedComposer,
        album: movieTitle,
        duration: 300,
        spotifyUrl: ApiConstants.generateSpotifySearchUrl(movieTitle, "end credits"),
        youtubeUrl: ApiConstants.generateYouTubeSearchUrl(movieTitle, "end credits"),
        audioUrl: "https://commondatastorage.googleapis.com/codeskulptor-demos/pyman_assets/ateapot.ogg",
      ),
    ];
    
    return MovieSoundtrack(
      movieId: movieId,
      movieTitle: movieTitle,
      composer: suggestedComposer,
      tracks: suggestedTracks,
    );
  }

  // Suggest composer based on movie title keywords
  String _getSuggestedComposer(String movieTitle) {
    final lowerTitle = movieTitle.toLowerCase();
    
    // Action/adventure movies
    if (lowerTitle.contains('action') || 
        lowerTitle.contains('mission') || 
        lowerTitle.contains('impossible') ||
        lowerTitle.contains('fast') ||
        lowerTitle.contains('furious')) {
      return "Steve Jablonsky";
    }
    
    // Sci-fi movies
    if (lowerTitle.contains('star') || 
        lowerTitle.contains('space') || 
        lowerTitle.contains('galaxy') ||
        lowerTitle.contains('alien') ||
        lowerTitle.contains('matrix')) {
      return "John Williams";
    }
    
    // Dark/thriller movies
    if (lowerTitle.contains('dark') || 
        lowerTitle.contains('knight') || 
        lowerTitle.contains('batman') ||
        lowerTitle.contains('murder') ||
        lowerTitle.contains('killer')) {
      return "Hans Zimmer";
    }
    
    // Fantasy/adventure
    if (lowerTitle.contains('lord') || 
        lowerTitle.contains('rings') || 
        lowerTitle.contains('hobbit') ||
        lowerTitle.contains('magic') ||
        lowerTitle.contains('dragon')) {
      return "Howard Shore";
    }
    
    // Marvel/superhero
    if (lowerTitle.contains('marvel') || 
        lowerTitle.contains('avengers') || 
        lowerTitle.contains('iron') ||
        lowerTitle.contains('captain') ||
        lowerTitle.contains('spider')) {
      return "Alan Silvestri";
    }
    
    // Default
    return "Various Artists";
  }

  // Generate Spotify search URL
  String _generateSpotifySearchUrl(String movieTitle, String trackType) {
    final query = Uri.encodeComponent('$movieTitle $trackType soundtrack');
    return 'https://open.spotify.com/search/$query';
  }

  // Generate YouTube search URL
  String _generateYouTubeSearchUrl(String movieTitle, String trackType) {
    final query = Uri.encodeComponent('$movieTitle $trackType soundtrack');
    return 'https://www.youtube.com/results?search_query=$query';
  }

  // Check if movie has soundtrack
  bool hasSoundtrack(int movieId) {
    return _movieSoundtracks.containsKey(movieId);
  }

  // Get a random popular soundtrack track
  SoundtrackTrack getRandomPopularTrack() {
    return _popularSoundtracks[_random.nextInt(_popularSoundtracks.length)];
  }

  // Get featured soundtrack tracks
  Future<List<SoundtrackTrack>> getFeaturedTracks({int count = 5}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final featured = <SoundtrackTrack>[];
    
    // Add popular tracks
    featured.addAll(_popularSoundtracks.take(2));
    
    // Add tracks from movie soundtracks
    final movieSoundtracks = _movieSoundtracks.values.toList()..shuffle(_random);
    for (final soundtrack in movieSoundtracks.take(3)) {
      if (soundtrack.mainThemes.isNotEmpty) {
        featured.add(soundtrack.mainThemes.first);
      } else if (soundtrack.tracks.isNotEmpty) {
        featured.add(soundtrack.tracks.first);
      }
    }
    
    // Shuffle and limit
    featured.shuffle(_random);
    return featured.take(count).toList();
  }

  // Launch external music service
  Future<bool> launchMusicService(SoundtrackTrack track, String service) async {
    String? url;
    
    switch (service.toLowerCase()) {
      case 'spotify':
        url = track.spotifyUrl;
        break;
      case 'youtube':
        url = track.youtubeUrl;
        break;
      case 'apple':
        url = track.appleMusicUrl;
        break;
    }
    
    if (url != null) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        print('Error launching URL: $e');
      }
    }
    
    return false;
  }

  // Search for soundtracks by movie title or composer
  Future<List<MovieSoundtrack>> searchSoundtracks(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (query.trim().isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return _movieSoundtracks.values.where((soundtrack) {
      return soundtrack.movieTitle.toLowerCase().contains(lowercaseQuery) ||
             (soundtrack.composer?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Get all available composers
  List<String> getAvailableComposers() {
    final composers = <String>{};
    for (final soundtrack in _movieSoundtracks.values) {
      if (soundtrack.composer != null) {
        composers.add(soundtrack.composer!);
      }
    }
    // Add popular composers
    composers.addAll(['John Williams', 'Hans Zimmer', 'Alan Silvestri', 'Howard Shore']);
    return composers.toList()..sort();
  }

  // Get soundtracks by composer
  Future<List<MovieSoundtrack>> getSoundtracksByComposer(String composer) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _movieSoundtracks.values.where((soundtrack) =>
        soundtrack.composer?.toLowerCase() == composer.toLowerCase()
    ).toList();
  }

  // Get track count for a movie
  int getTrackCount(int movieId) {
    return _movieSoundtracks[movieId]?.tracks.length ?? 0;
  }

  // Generate search URLs for different platforms
  Map<String, String> generateSearchUrls(String movieTitle, String? composer) {
    final encodedTitle = Uri.encodeComponent('$movieTitle soundtrack');
    final encodedComposer = composer != null ? Uri.encodeComponent('$composer $movieTitle') : encodedTitle;
    
    return {
      'spotify': 'https://open.spotify.com/search/$encodedTitle',
      'youtube': 'https://www.youtube.com/results?search_query=$encodedTitle',
      'apple': 'https://music.apple.com/search?term=$encodedComposer',
      'amazon': 'https://music.amazon.com/search/$encodedTitle',
      'soundcloud': 'https://soundcloud.com/search?q=$encodedTitle',
    };
  }

  /// Spotify search helper
  Future<List<String>> searchSpotifyTracks(String movieTitle) async {
    // This would need Spotify API credentials for full integration
    // For now, return search URLs
    return [
      ApiConstants.generateSpotifySearchUrl(movieTitle, 'main theme'),
      ApiConstants.generateSpotifySearchUrl(movieTitle, 'soundtrack'),
      ApiConstants.generateSpotifySearchUrl(movieTitle, 'score'),
    ];
  }

  /// YouTube search helper
  Future<List<String>> searchYouTubeTracks(String movieTitle) async {
    return [
      ApiConstants.generateYouTubeSearchUrl(movieTitle, 'main theme'),
      ApiConstants.generateYouTubeSearchUrl(movieTitle, 'soundtrack'),
      ApiConstants.generateYouTubeSearchUrl(movieTitle, 'score'),
      ApiConstants.generateYouTubeSearchUrl(movieTitle, 'music'),
    ];
  }

  /// Get working audio URL for testing
  String _getWorkingAudioUrl() {
    final urls = [
      "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3",
      "https://commondatastorage.googleapis.com/codeskulptor-demos/pang/paza-moduless.mp3",
      "https://commondatastorage.googleapis.com/codeskulptor-demos/GalaxyInvaders/theme_01.mp3",
    ];
    return urls[_random.nextInt(urls.length)];
  }
} 