import 'dart:io';

import 'package:flutter/material.dart';

/// 표지판 사진이 들어갈 자리.
///
/// [imagePath] 가 있으면 그 사진 파일을 보여주고, 없으면(지금은 항상 없음)
/// [icon] + [color] 로 만든 자리표시 박스를 대신 그린다. 나중에 실제 표지판
/// 사진을 붙일 때는 이 위젯에 [imagePath] 만 채워주면 된다.
class SignageImage extends StatelessWidget {
  const SignageImage({
    super.key,
    required this.icon,
    required this.color,
    this.imagePath,
    this.iconSize = 32,
    this.borderRadius = 12,
  });

  final IconData icon;
  final Color color;
  final String? imagePath;
  final double iconSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final path = imagePath;
    if (path != null) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.file(File(path), fit: BoxFit.cover),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}
