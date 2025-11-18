import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';
import '../../app_localizations.dart';

class PrimaryTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelKey;
  final String? Function(String?)? validator;
  final bool isRequired;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final bool hasError;
  final List<TextInputFormatter>? inputFormatters;

  const PrimaryTextFormField({
    super.key,
    required this.controller,
    required this.labelKey,
    this.validator,
    this.isRequired = true,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.hasError = false,
    this.inputFormatters,
  });

  @override
  State<PrimaryTextFormField> createState() => _PrimaryTextFormFieldState();
}

class _PrimaryTextFormFieldState extends State<PrimaryTextFormField>
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
        
        return TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: widget.isRequired 
              ? '${AppLocalizations.of(context).get(widget.labelKey)} *' 
              : AppLocalizations.of(context).get(widget.labelKey),
            labelStyle: TextStyle(
              color: widget.hasError ? kBrandNegativePrimary : Colors.grey[400],
              fontSize: 16,
            ),
            suffixIcon: widget.suffixIcon,
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
                if (value == null || value.isEmpty) {
                  final fieldName = AppLocalizations.of(context).get(widget.labelKey).toLowerCase();
                  return AppLocalizations.of(context).get('please-enter-field').replaceAll('{field}', fieldName);
                }
                return null;
              }
            : null),
        );
      },
    );
  }
}