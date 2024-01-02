import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _buttonDiameter = 60.0;

class DraggableFloatingActionButton extends StatefulWidget {
  final double scaleFactor;
  final Offset initialOffset;
  final double topPadding;
  final double bottomPadding;
  final double width;
  final double height;
  final VoidCallback? onPressed;
  final Function(Object) onError;

  const DraggableFloatingActionButton({
    super.key,
    required this.scaleFactor,
    required this.initialOffset,
    required this.topPadding,
    required this.bottomPadding,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.onError,
  });

  @override
  State<StatefulWidget> createState() => _DraggableFloatingActionButtonState();
}

class _DraggableFloatingActionButtonState
    extends State<DraggableFloatingActionButton> {
  final _key = GlobalKey(debugLabel: 'Testing #labeltestin');

  late Offset _offset;

  var _isDragging = false;
  var _minOffset = Offset.zero;
  var _maxOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
    WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
  }

  void _setBoundary(_) {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox;

    try {
      final size = renderBox.size;

      setState(() {
        _minOffset = Offset(0, widget.topPadding);
        _maxOffset = Offset(
          widget.width - size.width,
          widget.height - size.height,
        );
      });
    } catch (e) {
      widget.onError(e);
    }
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent, bool isDragging) {
    double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
    double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;

    if (newOffsetX < _minOffset.dx) {
      newOffsetX = _minOffset.dx;
    } else if (newOffsetX > _maxOffset.dx) {
      newOffsetX = _maxOffset.dx;
    }

    if (newOffsetY < _minOffset.dy) {
      newOffsetY = _minOffset.dy;
    } else if (newOffsetY > _maxOffset.dy) {
      newOffsetY = _maxOffset.dy;
    }

    final newOffset = Offset(newOffsetX, newOffsetY);
    if (newOffset == _offset) return;

    setState(() {
      _offset = Offset(newOffsetX, newOffsetY);
      _isDragging = isDragging;
    });
  }

  @override
  Widget build(BuildContext context) => Positioned(
        left: _offset.dx,
        top: _offset.dy,
        child: Listener(
          onPointerMove: (PointerMoveEvent pointerMoveEvent) {
            _updatePosition(pointerMoveEvent, true);
          },
          onPointerUp: (PointerUpEvent pointerUpEvent) {
            if (_isDragging) {
              HapticFeedback.mediumImpact();
              setState(() {
                _isDragging = false;
              });
            }
          },
          onPointerDown: (_) => HapticFeedback.mediumImpact(),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onPressed,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 100),
              scale: widget.scaleFactor,
              child: Container(
                key: _key,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0,
                      blurRadius: 5,
                      color: Colors.black.withOpacity(0.3),
                    )
                  ],
                ),
                child: Container(
                  width: _buttonDiameter,
                  height: _buttonDiameter,
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.question_mark,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
