/// A utility function to safely extract and convert values from JSON
/// 
/// Example usage:
/// ```dart
/// final id = getJsonField<int>(json, 'id');
/// final price = getJsonField<double>(json, 'price', defaultValue: 0.0);
/// final date = getJsonField<DateTime>(json, 'created_at');
/// final items = getJsonField<List<String>>(json, 'items');
/// ```
T? getJsonField<T>(Map<String, dynamic> json, String field, {T? defaultValue}) {
  try {
    final value = json[field];
    
    if (value == null) return defaultValue;
    
    // Handle List types
    if (T.toString().startsWith('List<')) {
      if (value is! List) return defaultValue;
      
      // Extract the type parameter from List<Type>
      final typeParam = T.toString().substring(5, T.toString().length - 1);
      
      switch (typeParam) {
        case 'int':
          return value.map((e) => int.tryParse(e.toString()) ?? 0).toList() as T;
        case 'double':
          return value.map((e) => double.tryParse(e.toString()) ?? 0.0).toList() as T;
        case 'String':
          return value.map((e) => e.toString()).toList() as T;
        case 'DateTime':
          return value.map((e) => DateTime.tryParse(e.toString())).toList() as T;
        default:
          return value as T;
      }
    }
    
    // Handle primitive types
    if (T == int) {
      return value is int 
        ? value as T
        : int.tryParse(value.toString()) as T?;
    }
    
    if (T == double) {
      return value is double 
        ? value as T
        : double.tryParse(value.toString()) as T?;
    }
    
    if (T == DateTime) {
      return value != null 
        ? DateTime.tryParse(value.toString()) as T?
        : null;
    }
    
    // For String and other types, return as is
    return value as T?;
  } catch (e) {
    print('Error parsing field "$field" as ${T.toString()}: $e');
    return defaultValue;
  }
}
