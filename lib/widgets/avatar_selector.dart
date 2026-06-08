import 'package:flutter/material.dart';
import '../config/theme.dart';

class AvatarSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AvatarSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const List<IconData> avatarIcons = [
    Icons.face_rounded,
    Icons.face_2_rounded,
    Icons.face_3_rounded,
    Icons.face_4_rounded,
    Icons.face_5_rounded,
    Icons.face_6_rounded,
    Icons.emoji_nature_rounded,
    Icons.emoji_food_beverage_rounded,
    Icons.pets_rounded,
    Icons.local_florist_rounded,
    Icons.favorite_rounded,
    Icons.star_rounded,
  ];

  static const List<Color> avatarColors = [
    Color(0xFFFFB6C1),
    Color(0xFFDDA0DD),
    Color(0xFFB0E0E6),
    Color(0xFFFFC0CB),
    Color(0xFFE6E6FA),
    Color(0xFFF0E68C),
    Color(0xFFA8E6CF),
    Color(0xFFFFDAB9),
    Color(0xFFE0BBE4),
    Color(0xFF98D8C8),
    Color(0xFFFF8A8A),
    Color(0xFFEAD9FF),
  ];

  static Widget buildAvatar(int index, {double size = 60}) {
    final i = index.clamp(0, avatarIcons.length - 1);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: avatarColors[i].withValues(alpha: 0.3),
        border: Border.all(color: avatarColors[i], width: 2),
      ),
      child: Icon(avatarIcons[i], size: size * 0.5, color: avatarColors[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: avatarIcons.length,
      itemBuilder: (context, index) {
        final isSelected = index == selectedIndex;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColors[index].withValues(alpha: isSelected ? 0.4 : 0.2),
              border: Border.all(
                color: isSelected ? AppColors.primaryPink : avatarColors[index],
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppColors.primaryPink.withValues(alpha: 0.3), blurRadius: 8)]
                  : [],
            ),
            child: Icon(
              avatarIcons[index],
              size: 28,
              color: avatarColors[index],
            ),
          ),
        );
      },
    );
  }
}
