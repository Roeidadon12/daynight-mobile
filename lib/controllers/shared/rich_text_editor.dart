import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

class RichTextEditor extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final Function(String)? onChanged;

  const RichTextEditor({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLines = 6,
    this.onChanged,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  QuillController? _quillController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize QuillController with existing text or empty document
    Document document;
    try {
      if (widget.controller.text.isNotEmpty) {
        // Try to parse as JSON (Quill format) first
        final json = jsonDecode(widget.controller.text);
        document = Document.fromJson(json);
      } else {
        document = Document();
      }
    } catch (e) {
      // If it's not JSON, treat as plain text
      if (widget.controller.text.isNotEmpty) {
        document = Document()..insert(0, widget.controller.text);
      } else {
        document = Document();
      }
    }
    
    _quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    
    // Listen to changes and update the original controller
    _quillController!.addListener(_onQuillChanged);
  }

  void _onQuillChanged() {
    if (_quillController != null) {
      final json = jsonEncode(_quillController!.document.toDelta().toJson());
      widget.controller.text = json;
      if (widget.onChanged != null) {
        widget.onChanged!(json);
      }
    }
  }

  @override
  void dispose() {
    _quillController?.removeListener(_onQuillChanged);
    _quillController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while controller is being initialized
    if (_quillController == null) {
      return Container(
        height: widget.maxLines * 24.0,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!, width: 1),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final double toolbarHeight = 60;
    final double editorHeight = widget.maxLines * 24.0;
    final double totalHeight = toolbarHeight + editorHeight;

    return Container(
      height: totalHeight,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Stack(
        children: [
          // Toolbar positioned at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: toolbarHeight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Bold Button
                      QuillToolbarToggleStyleButton(
                        controller: _quillController!,
                        attribute: Attribute.bold,
                        options: const QuillToolbarToggleStyleButtonOptions(
                          iconData: Icons.format_bold,
                        ),
                      ),
                      
                      // Italic Button
                      QuillToolbarToggleStyleButton(
                        controller: _quillController!,
                        attribute: Attribute.italic,
                        options: const QuillToolbarToggleStyleButtonOptions(
                          iconData: Icons.format_italic,
                        ),
                      ),
                      
                      // Font Size Button
                      QuillToolbarFontSizeButton(
                        controller: _quillController!,
                      ),
                      
                      // Link Button
                      QuillToolbarLinkStyleButton(
                        controller: _quillController!,
                      ),
                      
                      // Bullet List Button
                      QuillToolbarToggleStyleButton(
                        controller: _quillController!,
                        attribute: Attribute.ul,
                        options: const QuillToolbarToggleStyleButtonOptions(
                          iconData: Icons.format_list_bulleted,
                        ),
                      ),
                      
                      // Numbered List Button
                      QuillToolbarToggleStyleButton(
                        controller: _quillController!,
                        attribute: Attribute.ol,
                        options: const QuillToolbarToggleStyleButtonOptions(
                          iconData: Icons.format_list_numbered,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Editor positioned below toolbar
          Positioned(
            top: toolbarHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
                child: QuillEditor.basic(
                  controller: _quillController!,
                  focusNode: _focusNode,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}