import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../app_localizations.dart';

/// A generic expandable select field that shows an overlay list of options
/// when tapped. Selecting an option or tapping outside collapses the overlay.
///
/// Generic parameters:
/// T - the type of the selectable value (enum, model, etc.)
class ExpandableSelect<T> extends StatefulWidget {
  final String labelKey; // localization key for the field label
  final T? selected; // currently selected value
  final List<T> options; // list of all options
  final ValueChanged<T?> onChanged; // callback when selection changes
  final String Function(T, BuildContext) getLabel; // converts option to display string
  final bool isRequired; // whether to show '*' after label
  final bool hasError; // highlight field as error
  final double verticalSpacing; // vertical spacing between options
  final double? maxHeight; // max overlay height (scrolls if exceeded)
  final EdgeInsets optionPadding; // padding per option row
  final BorderRadius optionBorderRadius; // border radius for option highlight
  final bool barrierDismissible; // whether outside tap closes overlay

  const ExpandableSelect({
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
    this.barrierDismissible = true,
  });

  @override
  State<ExpandableSelect<T>> createState() => _ExpandableSelectState<T>();
}

class _ExpandableSelectState<T> extends State<ExpandableSelect<T>> {
  bool _expanded = false;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  Size? _fieldSize;

  void _toggle() {
    if (_expanded) {
      _hideOverlay();
      setState(() => _expanded = false);
    } else {
      _showOverlay();
      setState(() => _expanded = true);
    }
  }

  void _select(T value) {
    widget.onChanged(value);
    _hideOverlay();
    setState(() => _expanded = false);
  }

  void _measureField() {
    final ctx = _fieldKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null) {
        _fieldSize = box.size;
      }
    }
  }

  void _showOverlay() {
    _measureField();
    final overlay = Overlay.of(context);

    final list = _OptionsList<T>(
      options: widget.options,
      selected: widget.selected,
      getLabel: widget.getLabel,
      hasError: widget.hasError,
      onSelect: _select,
      verticalSpacing: widget.verticalSpacing,
      maxHeight: widget.maxHeight,
      optionPadding: widget.optionPadding,
      optionBorderRadius: widget.optionBorderRadius,
    );

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            if (widget.barrierDismissible)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _hideOverlay();
                    if (mounted) setState(() => _expanded = false);
                  },
                ),
              ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, (_fieldSize?.height ?? 56) + 8),
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: _fieldSize?.width ?? 240,
                    maxWidth: _fieldSize?.width ?? 480,
                  ),
                  child: list,
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(32);
    final outlineBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: widget.hasError ? kBrandNegativePrimary : Colors.grey[800]!,
        width: 1,
      ),
    );

    final labelText = widget.isRequired
        ? '${AppLocalizations.of(context).get(widget.labelKey)} *'
        : AppLocalizations.of(context).get(widget.labelKey);

    final selectedLabel = widget.selected != null
        ? widget.getLabel(widget.selected as T, context)
        : '';

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: InputDecorator(
          key: _fieldKey,
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
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: kBrandPrimary,
                width: 2,
              ),
            ),
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

class _OptionsList<T> extends StatelessWidget {
  final List<T> options;
  final T? selected;
  final String Function(T, BuildContext) getLabel;
  final bool hasError;
  final ValueChanged<T> onSelect;
  final double verticalSpacing;
  final double? maxHeight;
  final EdgeInsets optionPadding;
  final BorderRadius optionBorderRadius;

  const _OptionsList({
    required this.options,
    required this.selected,
    required this.getLabel,
    required this.hasError,
    required this.onSelect,
    required this.verticalSpacing,
    required this.maxHeight,
    required this.optionPadding,
    required this.optionBorderRadius,
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

    final decorated = Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: kMainBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasError ? kBrandNegativePrimary : Colors.grey[800]!,
          width: 1,
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
