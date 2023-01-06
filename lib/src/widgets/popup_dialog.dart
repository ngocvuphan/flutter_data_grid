///
/// Reference: flutter/lib/src/material/popup_menu.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const Duration _kPopupTransitionDuration = Duration(milliseconds: 300);
const double _kPopupCloseIntervalEnd = 2.0 / 3.0;
const double _kMaxPopupWidth = 320;
const double _kMinPopupWidth = 120;
const double _kPopupScreenPadding = 8.0;

class PopupDialog extends StatelessWidget {
  const PopupDialog({
    super.key,
    this.child,
    required this.dialogBuilder,
    this.onDismiss,
    this.withoutRipple = false,
  });

  final Widget? child;
  final Widget Function(BuildContext) dialogBuilder;
  final void Function(dynamic)? onDismiss;
  final bool withoutRipple;

  @override
  Widget build(BuildContext context) {
    return withoutRipple ? GestureDetector(onTap: () => _handleTap(context), child: child) : InkWell(onTap: () => _handleTap(context), child: child);
  }

  void _handleTap(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context, rootNavigator: false);
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    final RenderBox overlayRenderBox = navigator.overlay!.context.findRenderObject()! as RenderBox;
    const offset = Offset.zero;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(offset, ancestor: overlayRenderBox),
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero) + offset, ancestor: overlayRenderBox),
      ),
      Offset.zero & overlayRenderBox.size,
    );

    navigator
        .push(_PopupDialogRoute(
          position: position,
          capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
          child: dialogBuilder(context),
        ))
        .then(onDismiss ?? (value) {});
  }
}

class _PopupDialogRoute extends PopupRoute {
  _PopupDialogRoute({
    required this.position,
    required this.capturedThemes,
    required this.child,
  });

  final RelativeRect position;
  final CapturedThemes capturedThemes;
  final Widget child;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => _kPopupTransitionDuration;

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linear,
      reverseCurve: const Interval(0.0, _kPopupCloseIntervalEnd),
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final dialog = _Dialog(animation: animation, child: child);
    return CustomSingleChildLayout(
      delegate: _PopupDialogLayoutDelegate(
        position: position,
        avoidBounds: _avoidBounds(mediaQuery),
      ),
      child: capturedThemes.wrap(dialog),
    );
  }

  Set<Rect> _avoidBounds(MediaQueryData mediaQuery) {
    return DisplayFeatureSubScreen.avoidBounds(mediaQuery).toSet();
  }
}

class _PopupDialogLayoutDelegate extends SingleChildLayoutDelegate {
  _PopupDialogLayoutDelegate({
    required this.position,
    required this.avoidBounds,
  });

  final RelativeRect position;
  final Set<Rect> avoidBounds;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest).deflate(const EdgeInsets.all(_kPopupScreenPadding));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by getConstraintsForChild.
    // print("getPositionForChild(size: $size, childSize: $childSize, position: $position)");
    final childHeight = size.height - position.top - position.bottom;
    final childWidth = size.width - position.left - position.right;
    double y = position.top + childHeight;
    double x;
    if (position.left > position.right) {
      x = size.width - position.right - childSize.width;
    } else {
      x = position.left + childWidth;
    }
    final Offset wantedPosition = Offset(x, y);
    final Offset originCenter = position.toRect(Offset.zero & size).center;
    final Iterable<Rect> subScreens = DisplayFeatureSubScreen.subScreensInBounds(Offset.zero & size, avoidBounds);
    final Rect subScreen = _closestScreen(subScreens, originCenter);
    return _fitInsideScreen(subScreen, childSize, wantedPosition);
  }

  @override
  bool shouldRelayout(covariant _PopupDialogLayoutDelegate oldDelegate) {
    return position != oldDelegate.position || !setEquals(avoidBounds, oldDelegate.avoidBounds);
  }

  Rect _closestScreen(Iterable<Rect> screens, Offset point) {
    Rect closest = screens.first;
    for (final Rect screen in screens) {
      if ((screen.center - point).distance < (closest.center - point).distance) {
        closest = screen;
      }
    }
    return closest;
  }

  Offset _fitInsideScreen(Rect screen, Size childSize, Offset wantedPosition) {
    double x = wantedPosition.dx;
    double y = wantedPosition.dy;
    // Avoid going outside an area defined as the rectangle 8.0 pixels from the
    // edge of the screen in every direction.
    if (x < screen.left + _kPopupScreenPadding) {
      x = screen.left + _kPopupScreenPadding;
    } else if (x + childSize.width > screen.right - _kPopupScreenPadding) {
      x = screen.right - childSize.width - _kPopupScreenPadding;
    }
    if (y < screen.top + _kPopupScreenPadding) {
      y = _kPopupScreenPadding;
    } else if (y + childSize.height > screen.bottom - _kPopupScreenPadding) {
      y = screen.bottom - childSize.height - _kPopupScreenPadding;
    }

    return Offset(x, y);
  }
}

class _Dialog extends StatelessWidget {
  const _Dialog({
    required this.child,
    required this.animation,
  });

  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final dialog = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _kMaxPopupWidth, minWidth: _kMinPopupWidth),
      child: SingleChildScrollView(child: child),
    );

    final CurveTween opacity = CurveTween(curve: const Interval(0.0, 1.0 / 3.0));
    final CurveTween width = CurveTween(curve: const Interval(0.0, 1.0 / 2.5));
    final CurveTween height = CurveTween(curve: const Interval(0.0, 1.0 / 2.5));

    // return Material(
    //   type: MaterialType.card,
    //   elevation: 8.0,
    //   clipBehavior: Clip.antiAlias,
    //   child: dialog,
    // );

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: opacity.animate(animation),
          child: Material(
            type: MaterialType.card,
            elevation: 8.0,
            clipBehavior: Clip.antiAlias,
            child: Align(
              widthFactor: width.evaluate(animation),
              heightFactor: height.evaluate(animation),
              child: child,
            ),
          ),
        );
      },
      child: dialog,
    );
  }
}
