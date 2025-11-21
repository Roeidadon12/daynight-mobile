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
  final ValueChanged<bool>? onExpansionChanged; // callback when dropdown opens/closes

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
    this.onExpansionChanged,
  });

  @override
  State<ExpandableSelect<T>> createState() => _ExpandableSelectState<T>();
}

class _ExpandableSelectState<T> extends State<ExpandableSelect<T>>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

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
    setState(() => _expanded = !_expanded);
    
    if (_expanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    
    widget.onExpansionChanged?.call(_expanded);
  }

  void _select(T value) {
    widget.onChanged(value);
    setState(() => _expanded = false);
    _animationController.reverse();
    widget.onExpansionChanged?.call(false);
  }

  @override
  void dispose() {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The field itself
        AnimatedContainer(
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
        ),
        
        // The expandable options list
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            child: _OptionsList<T>(
              options: widget.options,
              selected: widget.selected,
              getLabel: widget.getLabel,
              hasError: widget.hasError,
              borderColor: borderColor,
              onSelect: _select,
              verticalSpacing: widget.verticalSpacing,
              maxHeight: widget.maxHeight,
              optionPadding: widget.optionPadding,
              optionBorderRadius: widget.optionBorderRadius,
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionsList<T> extends StatelessWidget {
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

  const _OptionsList({
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
