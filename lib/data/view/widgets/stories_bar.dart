import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  static const List<Map<String, String>> _stories = [
    {'name': 'Seu story', 'letter': '+'},
    {'name': 'carlos.dev', 'letter': 'C'},
    {'name': 'ana_foto', 'letter': 'A'},
    {'name': 'marcos_v', 'letter': 'M'},
    {'name': 'julia_fit', 'letter': 'J'},
    {'name': 'pedro_art', 'letter': 'P'},
    {'name': 'lucas_m', 'letter': 'L'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          final isFirst = index == 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isFirst
                        ? null
                        : const LinearGradient(
                            colors: AppColors.storyGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    border: isFirst
                        ? Border.all(
                            color: AppColors.primaryLight.withOpacity(0.5),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryDark,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          backgroundColor: isFirst
                              ? AppColors.surface
                              : AppColors.cardBackground,
                          child: isFirst
                              ? const Icon(
                                  Icons.add,
                                  color: AppColors.accent,
                                  size: 28,
                                )
                              : Text(
                                  story['letter']!,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 72,
                  child: Text(
                    story['name']!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
