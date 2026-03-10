import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import '../../app_localizations.dart';
import '../../constants.dart';

class FullPageDescriptionEditor extends StatefulWidget {
  final String initialContent;
  final String languageCode;
  final String languageName;
  final Function(String) onSave;

  const FullPageDescriptionEditor({
    super.key,
    required this.initialContent,
    required this.languageCode,
    required this.languageName,
    required this.onSave,
  });

  @override
  State<FullPageDescriptionEditor> createState() => _FullPageDescriptionEditorState();
}

class _FullPageDescriptionEditorState extends State<FullPageDescriptionEditor> {
  QuillController? _quillController;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _hasChanges = false;
  String _initialContent = '';

  @override
  void initState() {
    super.initState();
    
    // Store initial content for comparison
    _initialContent = widget.initialContent;
    
    print('FullPageDescriptionEditor: Initializing with content length: ${widget.initialContent.length}');
    
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Initialize QuillController with existing text or empty document
    Document document;
    try {
      if (widget.initialContent.isNotEmpty) {
        print('FullPageDescriptionEditor: Attempting to parse content as Quill JSON');
        // Try to parse as JSON (Quill format) first
        final json = jsonDecode(widget.initialContent);
        document = Document.fromJson(json);
        print('FullPageDescriptionEditor: Successfully parsed Quill JSON, document length: ${document.length}');
      } else {
        print('FullPageDescriptionEditor: No initial content, creating empty document');
        document = Document();
      }
    } catch (e) {
      print('FullPageDescriptionEditor: Failed to parse as JSON: $e');
      // If it's not JSON, treat as plain text
      if (widget.initialContent.isNotEmpty) {
        print('FullPageDescriptionEditor: Treating as plain text, length: ${widget.initialContent.length}');
        document = Document()..insert(0, widget.initialContent);
      } else {
        document = Document();
      }
    }
    
    _quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    
    print('FullPageDescriptionEditor: QuillController initialized');
    print('FullPageDescriptionEditor: Document plain text: "${_quillController!.document.toPlainText()}"');
    print('FullPageDescriptionEditor: Document length: ${_quillController!.document.length}');
    
    // Listen to changes
    _quillController!.addListener(_onQuillChanged);
    
    // Auto-focus after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        print('FullPageDescriptionEditor: Requesting focus');
        _focusNode.requestFocus();
        // Move cursor to end of document
        final docLength = _quillController!.document.length - 1;
        _quillController!.updateSelection(
          TextSelection.collapsed(offset: docLength > 0 ? docLength : 0),
          ChangeSource.local,
        );
        print('FullPageDescriptionEditor: Focus requested, cursor at position ${docLength > 0 ? docLength : 0}');
      }
    });
  }

  void _onQuillChanged() {
    // Check if content actually changed by comparing with initial
    if (_quillController != null) {
      final currentContent = jsonEncode(_quillController!.document.toDelta().toJson());
      final hasActualChanges = currentContent != _initialContent;
      
      if (_hasChanges != hasActualChanges) {
        print('FullPageDescriptionEditor: Changes detected: $hasActualChanges');
        setState(() {
          _hasChanges = hasActualChanges;
        });
      } else if (hasActualChanges) {
        // Still trigger rebuild to update placeholder/character count
        setState(() {});
      }
    }
  }

  void _saveAndClose() {
    if (_quillController != null) {
      final json = jsonEncode(_quillController!.document.toDelta().toJson());
      print('FullPageDescriptionEditor: Saving content, length: ${json.length}');
      print('FullPageDescriptionEditor: Plain text length: ${_quillController!.document.toPlainText().length}');
      widget.onSave(json);
    } else {
      print('FullPageDescriptionEditor: Warning - QuillController is null, cannot save');
    }
    Navigator.of(context).pop();
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            AppLocalizations.of(context).get('unsaved-changes'),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            AppLocalizations.of(context).get('unsaved-changes-message'),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                AppLocalizations.of(context).get('discard'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                _saveAndClose();
              },
              child: Text(
                AppLocalizations.of(context).get('save'),
                style: TextStyle(color: kBrandPrimary),
              ),
            ),
          ],
        ),
      );
      return shouldDiscard == false;
    }
    return true;
  }

  @override
  void dispose() {
    // Restore portrait orientation when leaving this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    _quillController?.removeListener(_onQuillChanged);
    _quillController?.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: kMainBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppLocalizations.of(context).get('create-event-description')} - ${widget.languageName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Debug info
              Text(
                'Initial: ${widget.initialContent.length} chars | Current: ${_getCurrentCharacterCount()} chars',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _saveAndClose,
              child: Text(
                AppLocalizations.of(context).get('save'),
                style: TextStyle(
                  color: kBrandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: _quillController == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Column(
                children: [
                  // Toolbar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[800]!, width: 1),
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
                            
                            // Underline Button
                            QuillToolbarToggleStyleButton(
                              controller: _quillController!,
                              attribute: Attribute.underline,
                              options: const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.format_underline,
                              ),
                            ),
                            
                            // Strikethrough Button
                            QuillToolbarToggleStyleButton(
                              controller: _quillController!,
                              attribute: Attribute.strikeThrough,
                              options: const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.strikethrough_s,
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            
                            // Font Size Button
                            QuillToolbarFontSizeButton(
                              controller: _quillController!,
                            ),
                            
                            // Text Color Button
                            QuillToolbarColorButton(
                              controller: _quillController!,
                              isBackground: false,
                            ),
                            
                            // Background Color Button
                            QuillToolbarColorButton(
                              controller: _quillController!,
                              isBackground: true,
                            ),
                            
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            
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
                            
                            // Checklist Button
                            QuillToolbarToggleCheckListButton(
                              controller: _quillController!,
                            ),
                            
                            // Code Block Button
                            QuillToolbarToggleStyleButton(
                              controller: _quillController!,
                              attribute: Attribute.codeBlock,
                              options: const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.code,
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            
                            // Quote/Blockquote Button
                            QuillToolbarToggleStyleButton(
                              controller: _quillController!,
                              attribute: Attribute.blockQuote,
                              options: const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.format_quote,
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            
                            // Text Alignment - Left
                            QuillToolbarToggleStyleButton(
                              controller: _quillController!,
                              attribute: Attribute.leftAlignment,
                              options: const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.format_align_left,
                              ),
                            ),
                            
                            // Text Alignment - Center
                            QuillToolbarToggleStyleButton(
                              controller: _quillController!,
                              attribute: Attribute.centerAlignment,
                              options: const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.format_align_center,
                              ),
                            ),
                            
                            // Text Alignment - Right
                            QuillToolbarToggleStyleButton(
                              controller: _quillController!,
                              attribute: Attribute.rightAlignment,
                              options: const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.format_align_right,
                              ),
                            ),
                            
                            // Text Alignment - Justify
                            QuillToolbarToggleStyleButton(
                              controller: _quillController!,
                              attribute: Attribute.justifyAlignment,
                              options: const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.format_align_justify,
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            
                            // Indent Button
                            QuillToolbarIndentButton(
                              controller: _quillController!,
                              isIncrease: true,
                            ),
                            
                            // Outdent Button
                            QuillToolbarIndentButton(
                              controller: _quillController!,
                              isIncrease: false,
                            ),
                            
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            
                            // Link Button
                            QuillToolbarLinkStyleButton(
                              controller: _quillController!,
                            ),
                            
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            
                            // Clear Formatting Button
                            QuillToolbarClearFormatButton(
                              controller: _quillController!,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Editor
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[900],
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show placeholder hint when empty
                            if (_quillController!.document.toPlainText().trim().isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  AppLocalizations.of(context).get('create-event-description-instructions'),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            DefaultTextStyle(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                              child: QuillEditor.basic(
                                controller: _quillController!,
                                focusNode: _focusNode,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Character count footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      border: Border(
                        top: BorderSide(color: Colors.grey[800]!, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context).get('description-minimum-characters'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_getCurrentCharacterCount()} ${AppLocalizations.of(context).get('characters')}',
                          style: TextStyle(
                            color: _getCurrentCharacterCount() >= 30 ? Colors.green : Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  int _getCurrentCharacterCount() {
    if (_quillController == null) return 0;
    
    try {
      final plainText = _quillController!.document.toPlainText();
      return plainText.trim().length;
    } catch (e) {
      return 0;
    }
  }
}
