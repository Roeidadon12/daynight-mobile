import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../app_localizations.dart';

class PrimaryDropdownField<T> extends StatefulWidget {
  final String labelKey;
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  final String Function(T, BuildContext) getLabel;
  final bool isRequired;
  final String? Function(T?)? validator;
  final bool hasError;

  const PrimaryDropdownField({
    super.key,
    required this.labelKey,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.getLabel,
    this.isRequired = true,
    this.validator,
    this.hasError = false,
  });

  @override
  State<PrimaryDropdownField<T>> createState() => _PrimaryDropdownFieldState<T>();
}

class _PrimaryDropdownFieldState<T> extends State<PrimaryDropdownField<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _borderColorAnimation = ColorTween(
      begin: Colors.grey[800],
      end: kBrandPrimary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(() {
      if (_focusNode.hasFocus != _isFocused) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
          if (_isFocused) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(32);
    
    return AnimatedBuilder(
      animation: _borderColorAnimation,
      builder: (context, child) {
        final borderColor = widget.hasError 
          ? kBrandNegativePrimary 
          : _borderColorAnimation.value ?? Colors.grey[800]!;
        
        final outlineBorder = OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: borderColor,
            width: _isFocused ? 2 : 1,
          ),
        );

        return DropdownButtonFormField<T>(
          initialValue: widget.value,
          focusNode: _focusNode,
          // Opened-list design: rounded items, clearer selection, better spacing
          items: widget.items.map((item) {
            final bool isSelected = widget.value == item;
            return DropdownMenuItem<T>(
              value: item,
              child: Container(
                // Do not force width; let dropdown constraints size it
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? kBrandPrimary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: isSelected
                      ? Border.all(
                          color: kBrandPrimary.withValues(alpha: 0.30),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  // Avoid flex-based expansion inside dropdown items (unbounded width)
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        widget.getLabel(item, context),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? kBrandPrimary : Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: kBrandPrimary,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: widget.onChanged,
          style: const TextStyle(color: Colors.white),
          // Use app constants; avoid deprecated withOpacity
          dropdownColor: kMainBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          elevation: 12,
          menuMaxHeight: 280,
          decoration: InputDecoration(
            labelText: widget.isRequired 
              ? '${AppLocalizations.of(context).get(widget.labelKey)} *'
              : AppLocalizations.of(context).get(widget.labelKey),
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
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: kBrandNegativePrimary,
                width: 2,
              ),
            ),
          ),
          validator: widget.validator ?? (widget.isRequired 
            ? (value) {
                if (value == null) {
                  final fieldName = AppLocalizations.of(context).get(widget.labelKey).toLowerCase();
                  return AppLocalizations.of(context).get('please-select-field').replaceAll('{field}', fieldName);
                }
                return null;
              }
            : null),
        );
      },
    );
  }
}

// Gender enum moved to models/gender.dart