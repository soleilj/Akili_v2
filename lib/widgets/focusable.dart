import 'package:flutter/material.dart';

import '../theme/akili_theme.dart';

/// Makes anything selectable with a TV remote (D-pad + OK), keyboard, mouse or
/// touch. When focused by remote/keyboard it grows slightly and shows a white
/// ring, the standard TV pattern. Touch users never see the ring.
class Focusable extends StatefulWidget {
  const Focusable({
    super.key,
    required this.child,
    this.onActivate,
    this.autofocus = false,
    this.focusNode,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.focusScale = 1.04,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onActivate;
  final bool autofocus;
  final FocusNode? focusNode;
  final BorderRadius borderRadius;
  final double focusScale;
  final String? semanticLabel;

  @override
  State<Focusable> createState() => _FocusableState();
}

class _FocusableState extends State<Focusable> {
  bool _highlighted = false;

  void _activate() => widget.onActivate?.call();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onActivate != null,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        mouseCursor: widget.onActivate != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        onShowFocusHighlight: (value) => setState(() => _highlighted = value),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onActivate == null ? null : _activate,
          child: AnimatedScale(
            scale: _highlighted ? widget.focusScale : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              foregroundDecoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                border: Border.all(
                  color: _highlighted ? AkiliColors.focus : Colors.transparent,
                  width: 3,
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
