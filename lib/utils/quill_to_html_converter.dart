/// Flexible Quill Delta to HTML converter
/// Allows easy extension of formatting features without modifying core logic
class QuillToHtmlConverter {
  // Map of attribute handlers - easily extensible
  static final Map<String, String Function(String text, dynamic value)> _formatters = {
    'bold': (text, value) => '<b>$text</b>',
    'italic': (text, value) => '<i>$text</i>',
    'underline': (text, value) => '<u>$text</u>',
    'strike': (text, value) => '<s>$text</s>',
    'color': (text, value) => '<span style="color: $value">$text</span>',
    'background': (text, value) => '<span style="background-color: $value">$text</span>',
    'size': (text, value) => '<span style="font-size: ${_mapSize(value)}">$text</span>',
    'header': (text, value) => '<h$value>$text</h$value>',
  };

  // Configuration - enable/disable features as needed
  static final Set<String> _enabledFeatures = {
    'bold',
    'italic', 
    'color',
    'size',
    // 'underline',  // commented out for mobile
    // 'header',     // commented out for mobile
  };

  /// Convert Quill Delta JSON to HTML
  static String convert(dynamic deltaJson) {
    try {
      List<dynamic> ops;
      
      if (deltaJson is List) {
        ops = deltaJson;
      } else if (deltaJson is Map<String, dynamic> && deltaJson.containsKey('ops')) {
        ops = deltaJson['ops'] as List<dynamic>;
      } else {
        return '';
      }
      
      StringBuffer htmlBuffer = StringBuffer();
      
      for (final op in ops) {
        if (op is Map<String, dynamic> && op.containsKey('insert')) {
          final insert = op['insert'];
          final attributes = op['attributes'] as Map<String, dynamic>?;
          
          if (insert is String) {
            String text = insert.replaceAll('\n', '<br>');
            
            // Apply formatting based on enabled features and attributes
            if (attributes != null) {
              text = _applyFormatting(text, attributes);
            }
            
            htmlBuffer.write(text);
          }
        }
      }
      
      return htmlBuffer.toString();
      
    } catch (e) {
      return '';
    }
  }

  /// Apply formatting attributes to text
  static String _applyFormatting(String text, Map<String, dynamic> attributes) {
    String result = text;
    
    // Sort attributes by priority (simple tags first, then complex ones)
    final sortedAttributes = attributes.entries.toList()
      ..sort((a, b) => _getAttributePriority(a.key).compareTo(_getAttributePriority(b.key)));
    
    for (final entry in sortedAttributes) {
      final attribute = entry.key;
      final value = entry.value;
      
      // Only apply if feature is enabled and formatter exists
      if (_enabledFeatures.contains(attribute) && _formatters.containsKey(attribute)) {
        result = _formatters[attribute]!(result, value);
      }
    }
    
    return result;
  }

  /// Get attribute priority for proper nesting (lower number = applied first)
  static int _getAttributePriority(String attribute) {
    switch (attribute) {
      case 'bold':
      case 'italic':
      case 'underline':
      case 'strike':
        return 1;
      case 'color':
      case 'background':
      case 'size':
        return 2;
      case 'header':
        return 3;
      default:
        return 4;
    }
  }

  /// Map Quill sizes to CSS pixel values
  static String _mapSize(dynamic size) {
    switch (size) {
      case 'small':
        return '12px';
      case 'large':
        return '18px';
      case 'huge':
        return '24px';
      default:
        // Handle custom sizes (like "14px" or numbers)
        if (size is String && size.endsWith('px')) {
          return size;
        } else if (size is num) {
          return '${size}px';
        }
        return '14px'; // default
    }
  }

  // === Extension Methods ===

  /// Add a custom formatter for new attributes
  static void addFormatter(String attribute, String Function(String text, dynamic value) formatter) {
    _formatters[attribute] = formatter;
  }

  /// Enable a formatting feature
  static void enableFeature(String attribute) {
    _enabledFeatures.add(attribute);
  }

  /// Disable a formatting feature
  static void disableFeature(String attribute) {
    _enabledFeatures.remove(attribute);
  }

  /// Get list of enabled features
  static Set<String> get enabledFeatures => Set.from(_enabledFeatures);

  /// Set multiple features at once
  static void setEnabledFeatures(Set<String> features) {
    _enabledFeatures.clear();
    _enabledFeatures.addAll(features);
  }

  /// Reset to default mobile-friendly configuration
  static void resetToMobileDefaults() {
    _enabledFeatures.clear();
    _enabledFeatures.addAll(['bold', 'italic', 'color', 'size']);
  }

  /// Enable all available features
  static void enableAllFeatures() {
    _enabledFeatures.clear();
    _enabledFeatures.addAll(_formatters.keys);
  }
}