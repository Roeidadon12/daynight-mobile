void main() {
  // Simulate the raw data that seems to be coming from the app
  // Based on debug output: firstName="1", lastName="1 Yahalom 1"
  final firstName = "1";
  final lastName = "1 Yahalom 1";
  
  print('=== Testing name parsing logic ===');
  print('Input firstName: "$firstName"');
  print('Input lastName: "$lastName"');
  
  // Simulate the logic from the updated code
  final fullRawName = '$firstName $lastName'.trim();
  print('Full raw name: "$fullRawName"');
  
  // Remove leading numbers and split properly
  final cleanedFullName = fullRawName.replaceFirst(RegExp(r'^\d+\s*'), '');
  print('Cleaned full name: "$cleanedFullName"');
  
  // Split the cleaned name: expecting something like "Oren 1 Yahalom 1"
  final nameParts = cleanedFullName.split(' ');
  print('Name parts: $nameParts');
  
  String cleanFirstName;
  String cleanLastName;
  
  if (nameParts.length >= 4) {
    // Format: "Oren 1 Yahalom 1" -> firstName="Oren 1", lastName="Yahalom 1"
    cleanFirstName = '${nameParts[0]} ${nameParts[1]}'; // "Oren 1"
    cleanLastName = '${nameParts[2]} ${nameParts[3]}';  // "Yahalom 1"
  } else if (nameParts.length == 3) {
    // Format: "Oren Yahalom 1" -> firstName="Oren", lastName="Yahalom 1"  
    cleanFirstName = nameParts[0];
    cleanLastName = '${nameParts[1]} ${nameParts[2]}';
  } else if (nameParts.length == 2) {
    // Format: "Oren Yahalom" -> firstName="Oren", lastName="Yahalom"
    cleanFirstName = nameParts[0];
    cleanLastName = nameParts[1];
  } else {
    // Fallback
    cleanFirstName = cleanedFullName;
    cleanLastName = '';
  }
  
  print('=== Result ===');
  print('Cleaned firstName: "$cleanFirstName"');
  print('Cleaned lastName: "$cleanLastName"');
  
  // Test what happens if the input was different
  print('\n=== Test with expected input ===');
  final testInput = "1 Oren 1 Yahalom 1"; 
  final testCleaned = testInput.replaceFirst(RegExp(r'^\d+\s*'), '');
  final testParts = testCleaned.split(' ');
  print('Test input: "$testInput"');
  print('Test cleaned: "$testCleaned"');
  print('Test parts: $testParts');
  
  if (testParts.length >= 4) {
    final testFirstName = '${testParts[0]} ${testParts[1]}';
    final testLastName = '${testParts[2]} ${testParts[3]}';
    print('Test firstName: "$testFirstName"');
    print('Test lastName: "$testLastName"');
  }
}