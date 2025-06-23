import 'package:mivi/data/models/movie_model.dart';

class MockMovies {
  static final List<Genre> genres = [
    const Genre(id: 28, name: 'Action'),
    const Genre(id: 12, name: 'Adventure'),
    const Genre(id: 16, name: 'Animation'),
    const Genre(id: 35, name: 'Comedy'),
    const Genre(id: 80, name: 'Crime'),
    const Genre(id: 99, name: 'Documentary'),
    const Genre(id: 18, name: 'Drama'),
    const Genre(id: 10751, name: 'Family'),
    const Genre(id: 14, name: 'Fantasy'),
    const Genre(id: 36, name: 'History'),
    const Genre(id: 27, name: 'Horror'),
    const Genre(id: 10402, name: 'Music'),
    const Genre(id: 9648, name: 'Mystery'),
    const Genre(id: 10749, name: 'Romance'),
    const Genre(id: 878, name: 'Science Fiction'),
    const Genre(id: 53, name: 'Thriller'),
    const Genre(id: 10752, name: 'War'),
    const Genre(id: 37, name: 'Western'),
  ];

  static final List<CastMember> mockCast = [
    const CastMember(
      id: 1,
      name: 'Tom Hanks',
      character: 'Forrest Gump',
      profilePath: '/path/to/profile1.jpg',
    ),
    const CastMember(
      id: 2,
      name: 'Robin Wright',
      character: 'Jenny Curran',
      profilePath: '/path/to/profile2.jpg',
    ),
    const CastMember(
      id: 3,
      name: 'Gary Sinise',
      character: 'Lieutenant Dan',
      profilePath: '/path/to/profile3.jpg',
    ),
  ];

  static final List<Movie> movies = [
    Movie(
      id: 1,
      title: 'Inception',
      overview: 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
      posterPath: 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/s3TBrRGB1iav7gFOCNx3H31MoES.jpg',
      voteAverage: 8.4,
      releaseDate: '2010-07-16',
      genres: [genres[0], genres[1], genres[14]], // Action, Adventure, Sci-Fi
      runtime: 148,
      tagline: 'Your mind is the scene of the crime.',
      status: 'Released',
      originalLanguage: 'en',
      budget: 160000000,
      revenue: 825532764,
      cast: mockCast,
      similarMovies: const [],
    ),
    Movie(
      id: 2,
      title: 'The Dark Knight',
      overview: 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
      posterPath: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/hkBaDkMWbLaf8B1lsWsKX7Ew3Xq.jpg',
      voteAverage: 8.5,
      releaseDate: '2008-07-18',
      genres: [genres[0], genres[6], genres[15]], // Action, Drama, Thriller
      runtime: 152,
      tagline: 'Why So Serious?',
      status: 'Released',
      originalLanguage: 'en',
      budget: 185000000,
      revenue: 1004558444,
      cast: mockCast,
      similarMovies: const [],
    ),
    Movie(
      id: 3,
      title: 'Pulp Fiction',
      overview: 'The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.',
      posterPath: 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/suaEOtk1N1sgg2QM528BRYQZqK5.jpg',
      voteAverage: 8.5,
      releaseDate: '1994-09-10',
      genres: [genres[6], genres[15]], // Drama, Thriller
      runtime: 154,
      tagline: 'Just because you are a character doesn\'t mean you have character.',
      status: 'Released',
      originalLanguage: 'en',
      budget: 8000000,
      revenue: 213928762,
      cast: mockCast,
      similarMovies: const [],
    ),
    Movie(
      id: 4,
      title: 'The Shawshank Redemption',
      overview: 'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.',
      posterPath: 'https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg',
      voteAverage: 8.7,
      releaseDate: '1994-09-23',
      genres: [genres[6]], // Drama
      runtime: 142,
      tagline: 'Fear can hold you prisoner. Hope can set you free.',
      status: 'Released',
      originalLanguage: 'en',
      budget: 25000000,
      revenue: 28341469,
      cast: mockCast,
      similarMovies: const [],
    ),
    Movie(
      id: 5,
      title: 'The Matrix',
      overview: 'A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.',
      posterPath: 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/2e7fc8eNwLXZ5Uvehvl5xj0P6Jw.jpg',
      voteAverage: 8.2,
      releaseDate: '1999-03-31',
      genres: [genres[0], genres[14]], // Action, Sci-Fi
      runtime: 136,
      tagline: 'Welcome to the Real World',
      status: 'Released',
      originalLanguage: 'en',
      budget: 63000000,
      revenue: 463517383,
      cast: mockCast,
      similarMovies: const [],
    ),
  ];

  static final List<Movie> _favorites = [];

  static List<Movie> get favoriteMovies => List.unmodifiable(_favorites);

  static void addToFavorites(Movie movie) {
    if (!_favorites.any((m) => m.id == movie.id)) {
      _favorites.add(movie);
    }
  }

  static void removeFromFavorites(Movie movie) {
    _favorites.removeWhere((m) => m.id == movie.id);
  }

  static List<Movie> get trendingMovies => movies;
  static List<Movie> get popularMovies => List.from(movies.reversed);
  static List<Movie> get topRatedMovies => List.from(movies)..sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
} 