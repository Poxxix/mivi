import 'package:flutter/material.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/presentation/widgets/genre_chip.dart';

class GenreList extends StatelessWidget {
  final List<Genre> genres;
  final Genre? selectedGenre;
  final Function(Genre) onGenreSelected;

  const GenreList({
    super.key,
    required this.genres,
    this.selectedGenre,
    required this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final genre = genres[index];
          return Padding(
            padding: EdgeInsets.only(
              right: 8,
              left: index == 0 ? 4 : 0,
            ),
            child: GenreChip(
              genre: genre,
              isSelected: selectedGenre?.id == genre.id,
              onTap: () => onGenreSelected(genre),
            ),
          );
        },
      ),
    );
  }
} 