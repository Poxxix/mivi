import 'package:flutter/material.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/presentation/core/app_colors.dart';
import 'package:mivi/presentation/widgets/cast_card.dart';

class CastList extends StatelessWidget {
  final String title;
  final List<CastMember> cast;
  final Function(CastMember)? onCastMemberTap;

  const CastList({
    super.key,
    required this.title,
    required this.cast,
    this.onCastMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cast.length,
            itemBuilder: (context, index) {
              final castMember = cast[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CastCard(
                  castMember: castMember,
                  onTap: onCastMemberTap != null ? () => onCastMemberTap!(castMember) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 