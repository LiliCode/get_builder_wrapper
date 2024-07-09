import 'package:flutter/material.dart';

/// 优化了 ElevatedButton 的使用
class CustomElevatedButton extends StatelessWidget {
  final Widget child;
  final double? radius;
  final BorderRadiusGeometry? borderRadius;
  final BorderSide? border;
  final Size? size;
  final Color? backgroundColor;
  final Color? disableColor;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final bool enable; // 是否开启交互
  final VoidCallback? onPressed;

  const CustomElevatedButton({
    super.key,
    required this.child,
    this.backgroundColor,
    this.disableColor = Colors.grey,
    this.borderRadius,
    this.border,
    this.radius,
    this.elevation = 0,
    this.size,
    this.padding,
    this.alignment,
    this.enable = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enable == false ? null : onPressed,
      style: ButtonStyle(
        alignment: alignment,
        padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(
          padding ?? EdgeInsets.zero,
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius:
                borderRadius ?? BorderRadius.circular(radius ?? 0), // 圆角半径
            side: border ?? BorderSide.none,
          ),
        ),
        fixedSize: size != null ? MaterialStatePropertyAll<Size>(size!) : null,
        elevation: MaterialStatePropertyAll<double>(elevation),
        backgroundColor: MaterialStatePropertyAll<Color>(
          enable == true
              ? (backgroundColor ?? Colors.transparent)
              : (disableColor ?? Colors.black26),
        ),
        enableFeedback: true, // 启用点击反馈
      ),
      child: child,
    );
  }
}
