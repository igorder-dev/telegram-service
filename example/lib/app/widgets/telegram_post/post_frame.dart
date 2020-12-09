import 'package:flutter/material.dart';

/// Defines Post containter with background, shadow and maximum width constraints
///
/// [child] - child widget for container
/// [maxWidth] - maximum withd of the container. Default is unlimitted
///
class PostFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color backgroundColor;
  final Color shadowColor;

  const PostFrame({
    Key key,
    this.maxWidth = double.infinity,
    @required this.child,
    this.backgroundColor,
    this.shadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            boxShadow: [
              BoxShadow(
                color: shadowColor ?? Colors.grey[600],
                offset: Offset(0, 3),
                blurRadius: 5.0,
                spreadRadius: -2.0,
              ),
            ],
          ),
          child: child,
        ),
      );
}
