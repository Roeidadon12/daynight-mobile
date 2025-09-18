import 'package:flutter/material.dart';

class HorizontalRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color color;

  const HorizontalRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color = Colors.blue,
  });

  @override
  State<HorizontalRefreshIndicator> createState() => _HorizontalRefreshIndicatorState();
}

class _HorizontalRefreshIndicatorState extends State<HorizontalRefreshIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRefreshing = false;
  double _dragOffset = 0.0;
  Offset _startPosition = Offset.zero;
  bool _isDragging = false;
  static const double _refreshTriggerPullDistance = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _dragOffset = 0.0;
          _isDragging = false;
        });
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _startPosition = details.localPosition;
        _isDragging = true;
        _controller.reset();
      },
      onHorizontalDragUpdate: (details) {
        if (!_isRefreshing && _isDragging) {
          final delta = details.localPosition.dx - _startPosition.dx;
          if (delta < 0) {  // Only allow pulling to the left
            setState(() {
              _dragOffset = delta;
              _controller.value = _dragOffset.abs() / _refreshTriggerPullDistance;
            });
          }
        }
      },
      onHorizontalDragEnd: (details) {
        if (_isDragging && !_isRefreshing && _dragOffset.abs() >= _refreshTriggerPullDistance) {
          _handleRefresh();
        } else {
          setState(() {
            _dragOffset = 0.0;
            _isDragging = false;
          });
          _controller.reverse();
        }
      },
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
          if (_dragOffset < 0)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 40,
                  margin: const EdgeInsets.only(left: 16),
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                    child: _isRefreshing
                        ? CircularProgressIndicator(color: widget.color)
                        : Icon(Icons.refresh, color: widget.color),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}