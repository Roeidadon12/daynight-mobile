import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../app_localizations.dart';

/// A specialized expandable select field that shows a full-width overlay 
/// when expanded, breaking out of layout constraints
class FullWidthExpandableSelect<T> extends StatefulWidget {
  final String labelKey;
  final T? selected;
  final List<T> options;
  final ValueChanged<T?> onChanged;
  final String Function(T, BuildContext) getLabel;
  final bool isRequired;
  final bool hasError;
  final double verticalSpacing;
  final double? maxHeight;
  final EdgeInsets optionPadding;
  final BorderRadius optionBorderRadius;
  final ValueChanged<bool>? onExpansionChanged;

  const FullWidthExpandableSelect({
    super.key,
    required this.labelKey,
    required this.selected,
    required this.options,
    required this.onChanged,
    required this.getLabel,
    this.isRequired = true,
    this.hasError = false,
    this.verticalSpacing = 4,
    this.maxHeight,
    this.optionPadding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.optionBorderRadius = const BorderRadius.all(Radius.circular(14)),
    this.onExpansionChanged,
  });

  @override
  State<FullWidthExpandableSelect<T>> createState() => _FullWidthExpandableSelectState<T>();
}

class _FullWidthExpandableSelectState<T> extends State<FullWidthExpandableSelect<T>>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  OverlayEntry? _overlayEntry;
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _toggle() {
    if (_expanded) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() => _expanded = true);
    _animationController.forward();
    widget.onExpansionChanged?.call(true);
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    setState(() => _expanded = false);
    _animationController.reverse();
    widget.onExpansionChanged?.call(false);
    
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _select(T value) {
    widget.onChanged(value);
    _closeDropdown();
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    
    return OverlayEntry(
      builder: (context) => Positioned(
        left: 16, // Full width with padding
        right: 16,
        top: position.dy + size.height + 8, // Position below the field
        child: Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) => SizeTransition(
              sizeFactor: _expandAnimation,
              child: _FullWidthOptionsList<T>(
                options: widget.options,
                selected: widget.selected,
                getLabel: widget.getLabel,
                hasError: widget.hasError,
                borderColor: widget.hasError 
                    ? kBrandNegativePrimary 
                    : kBrandPrimary,
                onSelect: _select,
                verticalSpacing: widget.verticalSpacing,
                maxHeight: widget.maxHeight,
                optionPadding: widget.optionPadding,
                optionBorderRadius: widget.optionBorderRadius,
                onTapOutside: _closeDropdown,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _closeDropdown();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(32);
    
    // Determine border color based on state
    final borderColor = widget.hasError 
        ? kBrandNegativePrimary 
        : _expanded 
            ? kBrandPrimary 
            : Colors.grey[800]!;
    
    final outlineBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: borderColor,
        width: _expanded ? 2 : 1,
      ),
    );

    final labelText = widget.isRequired
        ? '${AppLocalizations.of(context).get(widget.labelKey)} *'
        : AppLocalizations.of(context).get(widget.labelKey);

    final selectedLabel = widget.selected != null
        ? widget.getLabel(widget.selected as T, context)
        : '';

    return AnimatedContainer(
      key: _fieldKey,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: _toggle,
        child: InputDecorator(
          isEmpty: widget.selected == null,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(
              color: widget.hasError ? kBrandNegativePrimary : Colors.grey[400],
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.black.withAlpha(77),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            border: outlineBorder,
            enabledBorder: outlineBorder,
            focusedBorder: outlineBorder,
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: kBrandNegativePrimary,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedLabel,
                  style: TextStyle(
                    color: widget.selected != null ? Colors.white : Colors.grey[500],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullWidthOptionsList<T> extends StatelessWidget {
  final List<T> options;
  final T? selected;
  final String Function(T, BuildContext) getLabel;
  final bool hasError;
  final Color borderColor;
  final ValueChanged<T> onSelect;
  final double verticalSpacing;
  final double? maxHeight;
  final EdgeInsets optionPadding;
  final BorderRadius optionBorderRadius;
  final VoidCallback onTapOutside;

  const _FullWidthOptionsList({
    required this.options,
    required this.selected,
    required this.getLabel,
    required this.hasError,
    required this.borderColor,
    required this.onSelect,
    required this.verticalSpacing,
    required this.maxHeight,
    required this.optionPadding,
    required this.optionBorderRadius,
    required this.onTapOutside,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return InkWell(
          onTap: () => onSelect(opt),
          borderRadius: optionBorderRadius,
          child: Container(
            width: double.infinity,
            padding: optionPadding,
            margin: EdgeInsets.symmetric(vertical: verticalSpacing, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: optionBorderRadius,
              color: isSelected ? kBrandPrimary.withValues(alpha: 0.15) : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: kBrandPrimary.withValues(alpha: 0.30),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    getLabel(opt, context),
                    style: TextStyle(
                      color: isSelected ? kBrandPrimary : Colors.white,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: kBrandPrimary,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );

    final decorated = GestureDetector(
      onTap: onTapOutside, // Close when tapping on the overlay background
      child: Container(
        color: Colors.transparent, // Transparent background to catch taps
        child: GestureDetector(
          onTap: () {}, // Prevent taps on the list itself from closing
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: kMainBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: content,
          ),
        ),
      ),
    );

    if (maxHeight != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight!),
        child: SingleChildScrollView(child: decorated),
      );
    }
    return decorated;
  }
}