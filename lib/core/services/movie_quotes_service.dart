import 'dart:math';

class MovieQuote {
  final String quote;
  final String character;
  final String actor;
  final int movieId;
  final String movieTitle;

  const MovieQuote({
    required this.quote,
    required this.character,
    required this.actor,
    required this.movieId,
    required this.movieTitle,
  });

  Map<String, dynamic> toJson() {
    return {
      'quote': quote,
      'character': character,
      'actor': actor,
      'movieId': movieId,
      'movieTitle': movieTitle,
    };
  }

  factory MovieQuote.fromJson(Map<String, dynamic> json) {
    return MovieQuote(
      quote: json['quote'] as String,
      character: json['character'] as String,
      actor: json['actor'] as String,
      movieId: json['movieId'] as int,
      movieTitle: json['movieTitle'] as String,
    );
  }
}

class MovieQuotesService {
  static MovieQuotesService? _instance;
  static MovieQuotesService get instance => _instance ??= MovieQuotesService._();
  MovieQuotesService._();

  final Random _random = Random();

  // Mock quotes database - in real app this would come from an API
  static final Map<int, List<MovieQuote>> _movieQuotes = {
    1: [ // The Dark Knight
      MovieQuote(
        quote: "Why so serious?",
        character: "The Joker",
        actor: "Heath Ledger",
        movieId: 1,
        movieTitle: "The Dark Knight",
      ),
      MovieQuote(
        quote: "I'm not a monster. I'm just ahead of the curve.",
        character: "The Joker",
        actor: "Heath Ledger",
        movieId: 1,
        movieTitle: "The Dark Knight",
      ),
      MovieQuote(
        quote: "You either die a hero, or live long enough to see yourself become the villain.",
        character: "Harvey Dent",
        actor: "Aaron Eckhart",
        movieId: 1,
        movieTitle: "The Dark Knight",
      ),
      MovieQuote(
        quote: "It's not who I am underneath, but what I do that defines me.",
        character: "Bruce Wayne",
        actor: "Christian Bale",
        movieId: 1,
        movieTitle: "The Dark Knight",
      ),
    ],
    2: [ // Inception
      MovieQuote(
        quote: "We need to go deeper.",
        character: "Dom Cobb",
        actor: "Leonardo DiCaprio",
        movieId: 2,
        movieTitle: "Inception",
      ),
      MovieQuote(
        quote: "An idea is like a virus. Resilient. Highly contagious.",
        character: "Dom Cobb",
        actor: "Leonardo DiCaprio",
        movieId: 2,
        movieTitle: "Inception",
      ),
      MovieQuote(
        quote: "Dreams feel real while we're in them. It's only when we wake up that we realize something was actually strange.",
        character: "Dom Cobb",
        actor: "Leonardo DiCaprio",
        movieId: 2,
        movieTitle: "Inception",
      ),
      MovieQuote(
        quote: "You mustn't be afraid to dream a little bigger, darling.",
        character: "Eames",
        actor: "Tom Hardy",
        movieId: 2,
        movieTitle: "Inception",
      ),
    ],
    3: [ // Pulp Fiction
      MovieQuote(
        quote: "I'm gonna get medieval on your ass.",
        character: "Marsellus Wallace",
        actor: "Ving Rhames",
        movieId: 3,
        movieTitle: "Pulp Fiction",
      ),
      MovieQuote(
        quote: "Royale with cheese.",
        character: "Vincent Vega",
        actor: "John Travolta",
        movieId: 3,
        movieTitle: "Pulp Fiction",
      ),
      MovieQuote(
        quote: "Say 'what' again. I dare you.",
        character: "Jules Winnfield",
        actor: "Samuel L. Jackson",
        movieId: 3,
        movieTitle: "Pulp Fiction",
      ),
      MovieQuote(
        quote: "The path of the righteous man is beset on all sides...",
        character: "Jules Winnfield",
        actor: "Samuel L. Jackson",
        movieId: 3,
        movieTitle: "Pulp Fiction",
      ),
    ],
    4: [ // The Shawshank Redemption
      MovieQuote(
        quote: "Get busy living, or get busy dying.",
        character: "Andy Dufresne",
        actor: "Tim Robbins",
        movieId: 4,
        movieTitle: "The Shawshank Redemption",
      ),
      MovieQuote(
        quote: "Hope is a good thing, maybe the best of things, and no good thing ever dies.",
        character: "Andy Dufresne",
        actor: "Tim Robbins",
        movieId: 4,
        movieTitle: "The Shawshank Redemption",
      ),
      MovieQuote(
        quote: "I guess it comes down to a simple choice, really. Get busy living or get busy dying.",
        character: "Andy Dufresne",
        actor: "Tim Robbins",
        movieId: 4,
        movieTitle: "The Shawshank Redemption",
      ),
      MovieQuote(
        quote: "Remember Red, hope is a good thing, maybe the best of things, and no good thing ever dies.",
        character: "Andy Dufresne",
        actor: "Tim Robbins",
        movieId: 4,
        movieTitle: "The Shawshank Redemption",
      ),
    ],
    5: [ // The Matrix
      MovieQuote(
        quote: "There is no spoon.",
        character: "Spoon Boy",
        actor: "Rowan Witt",
        movieId: 5,
        movieTitle: "The Matrix",
      ),
      MovieQuote(
        quote: "Welcome to the real world.",
        character: "Morpheus",
        actor: "Laurence Fishburne",
        movieId: 5,
        movieTitle: "The Matrix",
      ),
      MovieQuote(
        quote: "I know kung fu.",
        character: "Neo",
        actor: "Keanu Reeves",
        movieId: 5,
        movieTitle: "The Matrix",
      ),
      MovieQuote(
        quote: "Unfortunately, no one can be told what the Matrix is. You have to see it for yourself.",
        character: "Morpheus",
        actor: "Laurence Fishburne",
        movieId: 5,
        movieTitle: "The Matrix",
      ),
    ],
    6: [ // Forrest Gump
      MovieQuote(
        quote: "Life is like a box of chocolates. You never know what you're gonna get.",
        character: "Forrest Gump",
        actor: "Tom Hanks",
        movieId: 6,
        movieTitle: "Forrest Gump",
      ),
      MovieQuote(
        quote: "Stupid is as stupid does.",
        character: "Forrest Gump",
        actor: "Tom Hanks",
        movieId: 6,
        movieTitle: "Forrest Gump",
      ),
      MovieQuote(
        quote: "Run, Forrest, run!",
        character: "Jenny Curran",
        actor: "Robin Wright",
        movieId: 6,
        movieTitle: "Forrest Gump",
      ),
      MovieQuote(
        quote: "My mama always said life was like a box of chocolates.",
        character: "Forrest Gump",
        actor: "Tom Hanks",
        movieId: 6,
        movieTitle: "Forrest Gump",
      ),
    ],
  };

  // Popular quotes from various movies
  static final List<MovieQuote> _popularQuotes = [
    MovieQuote(
      quote: "May the Force be with you.",
      character: "Various",
      actor: "Various",
      movieId: 0,
      movieTitle: "Star Wars",
    ),
    MovieQuote(
      quote: "I'll be back.",
      character: "The Terminator",
      actor: "Arnold Schwarzenegger",
      movieId: 0,
      movieTitle: "The Terminator",
    ),
    MovieQuote(
      quote: "Here's looking at you, kid.",
      character: "Rick Blaine",
      actor: "Humphrey Bogart",
      movieId: 0,
      movieTitle: "Casablanca",
    ),
    MovieQuote(
      quote: "You can't handle the truth!",
      character: "Colonel Jessup",
      actor: "Jack Nicholson",
      movieId: 0,
      movieTitle: "A Few Good Men",
    ),
    MovieQuote(
      quote: "Houston, we have a problem.",
      character: "Jim Lovell",
      actor: "Tom Hanks",
      movieId: 0,
      movieTitle: "Apollo 13",
    ),
  ];

  // Get quotes for a specific movie
  Future<List<MovieQuote>> getMovieQuotes(int movieId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final quotes = _movieQuotes[movieId] ?? [];
    
    // If no specific quotes found, return some popular quotes
    if (quotes.isEmpty) {
      return _getRandomPopularQuotes(3);
    }
    
    return quotes;
  }

  // Get a random quote from a movie
  Future<MovieQuote?> getRandomMovieQuote(int movieId) async {
    final quotes = await getMovieQuotes(movieId);
    if (quotes.isEmpty) return null;
    
    return quotes[_random.nextInt(quotes.length)];
  }

  // Get random popular quotes
  List<MovieQuote> _getRandomPopularQuotes(int count) {
    final shuffled = List<MovieQuote>.from(_popularQuotes)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  // Get daily quote (changes once per day)
  MovieQuote getDailyQuote() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final allQuotes = <MovieQuote>[];
    
    // Combine all movie quotes
    _movieQuotes.values.forEach((quotes) => allQuotes.addAll(quotes));
    allQuotes.addAll(_popularQuotes);
    
    // Use day of year as seed for consistent daily quote
    final index = dayOfYear % allQuotes.length;
    return allQuotes[index];
  }

  // Search quotes by text
  Future<List<MovieQuote>> searchQuotes(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (query.trim().isEmpty) return [];
    
    final allQuotes = <MovieQuote>[];
    _movieQuotes.values.forEach((quotes) => allQuotes.addAll(quotes));
    allQuotes.addAll(_popularQuotes);
    
    final lowercaseQuery = query.toLowerCase();
    return allQuotes.where((quote) {
      return quote.quote.toLowerCase().contains(lowercaseQuery) ||
             quote.character.toLowerCase().contains(lowercaseQuery) ||
             quote.actor.toLowerCase().contains(lowercaseQuery) ||
             quote.movieTitle.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get quotes by character
  Future<List<MovieQuote>> getQuotesByCharacter(String character) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final allQuotes = <MovieQuote>[];
    _movieQuotes.values.forEach((quotes) => allQuotes.addAll(quotes));
    allQuotes.addAll(_popularQuotes);
    
    return allQuotes.where((quote) => 
      quote.character.toLowerCase().contains(character.toLowerCase())
    ).toList();
  }

  // Get quotes by actor
  Future<List<MovieQuote>> getQuotesByActor(String actor) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final allQuotes = <MovieQuote>[];
    _movieQuotes.values.forEach((quotes) => allQuotes.addAll(quotes));
    allQuotes.addAll(_popularQuotes);
    
    return allQuotes.where((quote) => 
      quote.actor.toLowerCase().contains(actor.toLowerCase())
    ).toList();
  }

  // Get featured quotes (mix of popular and random)
  Future<List<MovieQuote>> getFeaturedQuotes({int count = 5}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final featured = <MovieQuote>[];
    
    // Add some popular quotes
    featured.addAll(_getRandomPopularQuotes(2));
    
    // Add some movie-specific quotes
    final movieIds = _movieQuotes.keys.toList()..shuffle(_random);
    for (final movieId in movieIds.take(3)) {
      final quotes = _movieQuotes[movieId]!;
      if (quotes.isNotEmpty) {
        featured.add(quotes[_random.nextInt(quotes.length)]);
      }
    }
    
    // Shuffle and limit
    featured.shuffle(_random);
    return featured.take(count).toList();
  }

  // Check if movie has quotes
  bool hasQuotes(int movieId) {
    return _movieQuotes.containsKey(movieId) && _movieQuotes[movieId]!.isNotEmpty;
  }

  // Get quote count for a movie
  int getQuoteCount(int movieId) {
    return _movieQuotes[movieId]?.length ?? 0;
  }
} 