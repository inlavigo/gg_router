// @license
// Copyright (c) 2019 - 2023 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';

abstract class GgAnimation extends StatelessWidget {
  const GgAnimation({
    super.key,
    required this.animation,
    required this.child,
    required this.size,
  });

  final Animation animation;
  final Widget child;
  final Size size;
}

// ######################
// Horizontal movement
// ######################

// Right

/// Move widget out from right
class GgMoveInFromRight extends GgAnimation {
  GgMoveInFromRight({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(
            (1.0 - Curves.easeInOut.transform(animation.value)) * size.width,
            0),
        child: child);
  }
}

// .............................................................................
/// Move widget out from right
class GgMoveOutToRight extends GgAnimation {
  GgMoveOutToRight({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset:
          Offset(Curves.easeInOut.transform(animation.value) * size.width, 0),
      child: child,
    );
  }
}

// Left

// .............................................................................
/// Move widget in from left
class GgMoveInFromLeft extends GgAnimation {
  GgMoveInFromLeft({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(
            (-1.0 + Curves.easeInOut.transform(animation.value)) * size.width,
            0),
        child: child);
  }
}

// .............................................................................
/// Move widget out to left
class GgMoveOutToLeft extends GgAnimation {
  GgMoveOutToLeft({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset:
          Offset(-Curves.easeInOut.transform(animation.value) * size.width, 0),
      child: child,
    );
  }
}

// ######################
// Vertical movement
// ######################

// Top

// .............................................................................
/// Move widget in from top
class GgMoveInFromTop extends GgAnimation {
  GgMoveInFromTop({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(0,
            (-1.0 + Curves.easeInOut.transform(animation.value)) * size.height),
        child: child);
  }
}

// .............................................................................
/// Move widget out to top
class GgMoveOutToTop extends GgAnimation {
  GgMoveOutToTop({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset:
          Offset(0, -Curves.easeInOut.transform(animation.value) * size.height),
      child: child,
    );
  }
}

// Bottom

// .............................................................................
/// Move widget in from bottom
class GgMoveInFromBottom extends GgAnimation {
  GgMoveInFromBottom({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(0,
            (1.0 - Curves.easeInOut.transform(animation.value)) * size.height),
        child: child);
  }
}

// .............................................................................
/// Move widget out to bottom
class GgMoveOutToBottom extends GgAnimation {
  GgMoveOutToBottom({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset:
          Offset(0, Curves.easeInOut.transform(animation.value) * size.height),
      child: child,
    );
  }
}

// ######################
// Diagonal movement
// ######################

// Bottom right

// .............................................................................
/// Move widget in from bottom right
class GgMoveInFromBottomRight extends GgAnimation {
  GgMoveInFromBottomRight({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return GgMoveInFromBottom(
      animation: animation,
      child: GgMoveInFromRight(animation: animation, child: child, size: size),
      size: size,
    );
  }
}

// .............................................................................
/// Move widget out to bottom right
class GgMoveOutToBottomRight extends GgAnimation {
  GgMoveOutToBottomRight({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return GgMoveOutToBottom(
        animation: animation,
        child: GgMoveOutToRight(animation: animation, child: child, size: size),
        size: size);
  }
}

// Bottom left

// .............................................................................
/// Move widget in from bottom left
class GgMoveInFromBottomLeft extends GgAnimation {
  GgMoveInFromBottomLeft({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return GgMoveInFromBottom(
      animation: animation,
      child: GgMoveInFromLeft(animation: animation, child: child, size: size),
      size: size,
    );
  }
}

// .............................................................................
/// Move widget out to bottom left
class GgMoveOutToBottomLeft extends GgAnimation {
  GgMoveOutToBottomLeft({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return GgMoveOutToBottom(
      animation: animation,
      child: GgMoveOutToLeft(animation: animation, child: child, size: size),
      size: size,
    );
  }
}

// Top right

// .............................................................................
/// Move widget in from top right
class GgMoveInFromTopRight extends GgAnimation {
  GgMoveInFromTopRight({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return GgMoveInFromTop(
      animation: animation,
      child: GgMoveInFromRight(animation: animation, child: child, size: size),
      size: size,
    );
  }
}

// .............................................................................
/// Move widget out to top right
class GgMoveOutToTopRight extends GgAnimation {
  GgMoveOutToTopRight({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return GgMoveOutToTop(
      animation: animation,
      child: GgMoveOutToRight(animation: animation, child: child, size: size),
      size: size,
    );
  }
}

// Top left

// .............................................................................
/// Move widget in from top left
class GgMoveInFromTopLeft extends GgAnimation {
  GgMoveInFromTopLeft({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return GgMoveInFromTop(
      animation: animation,
      child: GgMoveInFromLeft(animation: animation, child: child, size: size),
      size: size,
    );
  }
}

// .............................................................................
/// Move widget out to top left
class GgMoveOutToTopLeft extends GgAnimation {
  GgMoveOutToTopLeft({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return GgMoveOutToTop(
      animation: animation,
      child: GgMoveOutToLeft(animation: animation, child: child, size: size),
      size: size,
    );
  }
}

// ######################
// Fade translations
// ######################

// .............................................................................
/// Fade widget in
class GgFadeIn extends GgAnimation {
  GgFadeIn({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: Curves.easeInOut.transform(animation.value),
      child: child,
    );
  }
}

// .............................................................................
/// Fade widget out
class GgFadeOut extends GgAnimation {
  GgFadeOut({
    super.key,
    required super.animation,
    required super.child,
    required super.size,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: Curves.easeInOut.transform(1.0 - animation.value),
      child: child,
    );
  }
}
