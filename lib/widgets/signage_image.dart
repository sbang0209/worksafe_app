import 'package:flutter/material.dart';

/// 표지판 그림이 들어갈 자리.
///
/// [assetPath] 의 이미지를 비율을 유지한 채(BoxFit.contain) 보여준다.
/// 경로가 없거나 이미지를 불러오지 못하면 [icon] + [color] 로 만든 자리표시
/// 박스를 대신 그려서, 그림 하나가 빠져도 카드가 비어 보이지 않게 한다.
class SignageImage extends StatelessWidget {
  const SignageImage({
    super.key,
    required this.icon,
    required this.color,
    this.assetPath,
    this.iconSize = 32,
    this.borderRadius = 12,
  });

  final IconData icon;
  final Color color;

  /// 'assets/signs/forklift.png' 같은 애셋 경로.
  final String? assetPath;

  final double iconSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final path = assetPath;
    if (path == null) return _fallback(radius);
    return ClipRRect(
      borderRadius: radius,
      child: Padding(
        // 그림이 모서리에 딱 붙지 않게 살짝 띄운다.
        padding: const EdgeInsets.all(4),
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          // 파일이 없거나 깨진 경우에도 앱이 멈추지 않고 아이콘으로 대체된다.
          errorBuilder: (context, error, stackTrace) => _fallback(radius),
        ),
      ),
    );
  }

  Widget _fallback(BorderRadius radius) {
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
