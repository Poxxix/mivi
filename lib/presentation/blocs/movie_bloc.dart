import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/repositories/movie_repository.dart';

// Events
abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrendingMovies extends MovieEvent {
  final int page;
  final bool checkForNotifications;

  const LoadTrendingMovies({this.page = 1, this.checkForNotifications = false});

  @override
  List<Object?> get props => [page, checkForNotifications];
}

class LoadPopularMovies extends MovieEvent {
  final int page;

  const LoadPopularMovies({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class LoadTopRatedMovies extends MovieEvent {
  final int page;

  const LoadTopRatedMovies({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class LoadUpcomingMovies extends MovieEvent {
  final int page;

  const LoadUpcomingMovies({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class LoadNowPlayingMovies extends MovieEvent {
  final int page;

  const LoadNowPlayingMovies({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class LoadMovieDetails extends MovieEvent {
  final int movieId;

  const LoadMovieDetails(this.movieId);

  @override
  List<Object?> get props => [movieId];
}

class LoadMovieWithCredits extends MovieEvent {
  final int movieId;

  const LoadMovieWithCredits(this.movieId);

  @override
  List<Object?> get props => [movieId];
}

class SearchMovies extends MovieEvent {
  final String query;
  final int page;

  const SearchMovies(this.query, {this.page = 1});

  @override
  List<Object?> get props => [query, page];
}

class LoadSimilarMovies extends MovieEvent {
  final int movieId;
  final int page;

  const LoadSimilarMovies(this.movieId, {this.page = 1});

  @override
  List<Object?> get props => [movieId, page];
}

class LoadMoviesByGenre extends MovieEvent {
  final int genreId;
  final int page;

  const LoadMoviesByGenre(this.genreId, {this.page = 1});

  @override
  List<Object?> get props => [genreId, page];
}

// States
abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object?> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<Movie> movies;

  const MovieLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

class MovieDetailLoaded extends MovieState {
  final Movie movie;

  const MovieDetailLoaded(this.movie);

  @override
  List<Object?> get props => [movie];
}

class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository _movieRepository;

  MovieBloc({required MovieRepository movieRepository})
      : _movieRepository = movieRepository,
        super(MovieInitial()) {
    on<LoadTrendingMovies>(_onLoadTrendingMovies);
    on<LoadPopularMovies>(_onLoadPopularMovies);
    on<LoadTopRatedMovies>(_onLoadTopRatedMovies);
    on<LoadUpcomingMovies>(_onLoadUpcomingMovies);
    on<LoadNowPlayingMovies>(_onLoadNowPlayingMovies);
    on<LoadMovieDetails>(_onLoadMovieDetails);
    on<LoadMovieWithCredits>(_onLoadMovieWithCredits);
    on<SearchMovies>(_onSearchMovies);
    on<LoadSimilarMovies>(_onLoadSimilarMovies);
    on<LoadMoviesByGenre>(_onLoadMoviesByGenre);
  }

  Future<void> _onLoadTrendingMovies(
    LoadTrendingMovies event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    try {
      final movies = await _movieRepository.getTrendingMovies(
        page: event.page, 
        checkForNotifications: event.checkForNotifications,
      );
      emit(MovieLoaded(movies));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> _onLoadPopularMovies(
    LoadPopularMovies event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    try {
      final movies = await _movieRepository.getPopularMovies(page: event.page);
      emit(MovieLoaded(movies));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> _onLoadTopRatedMovies(
    LoadTopRatedMovies event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    try {
      final movies = await _movieRepository.getTopRatedMovies(page: event.page);
      emit(MovieLoaded(movies));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> _onLoadUpcomingMovies(
    LoadUpcomingMovies event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    try {
      final movies = await _movieRepository.getUpcomingMovies(page: event.page);
      emit(MovieLoaded(movies));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> _onLoadNowPlayingMovies(
    LoadNowPlayingMovies event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    try {
      final movies = await _movieRepository.getNowPlayingMovies(page: event.page);
      emit(MovieLoaded(movies));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> _onLoadMovieDetails(
    LoadMovieDetails event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    try {
      final movie = await _movieRepository.getMovieDetails(event.movieId);
      emit(MovieDetailLoaded(movie));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> _onLoadMovieWithCredits(
    LoadMovieWithCredits event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    try {
      final movie = await _movieRepository.getMovieWithCredits(event.movieId);
      emit(MovieDetailLoaded(movie));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> _onSearchMovies(
    SearchMovies event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    try {
      final movies = await _movieRepository.searchMovies(event.query, page: event.page);
      emit(MovieLoaded(movies));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> _onLoadSimilarMovies(
    LoadSimilarMovies event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    try {
      final movies = await _movieRepository.getSimilarMovies(event.movieId, page: event.page);
      emit(MovieLoaded(movies));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> _onLoadMoviesByGenre(
    LoadMoviesByGenre event,
    Emitter<MovieState> emit,
  ) async {
    emit(MovieLoading());
    try {
      final movies = await _movieRepository.getMoviesByGenre(event.genreId, page: event.page);
      emit(MovieLoaded(movies));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }
} 