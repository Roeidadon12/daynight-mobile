/// Country codes utility for the app
/// Provides a centralized list of country codes with their flags and names
class CountryCode {
  final String code;
  final String name;
  final String flag;
  final bool enabled;

  const CountryCode({
    required this.code,
    required this.name,
    required this.flag,
    this.enabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'flag': flag,
      'enabled': enabled,
    };
  }
}

class CountryCodes {
  static const List<CountryCode> _allCountryCodes = [
    CountryCode(code: '+972', name: 'Israel', flag: '🇮🇱', enabled: true),
    CountryCode(code: '+1', name: 'USA/Canada', flag: '🇺🇸', enabled: false),
    CountryCode(code: '+44', name: 'UK', flag: '🇬🇧', enabled: false),
    CountryCode(code: '+33', name: 'France', flag: '🇫🇷', enabled: false),
    CountryCode(code: '+49', name: 'Germany', flag: '🇩🇪', enabled: false),
    CountryCode(code: '+39', name: 'Italy', flag: '🇮🇹', enabled: false),
    CountryCode(code: '+34', name: 'Spain', flag: '🇪🇸', enabled: false),
    CountryCode(code: '+31', name: 'Netherlands', flag: '🇳🇱', enabled: false),
    CountryCode(code: '+41', name: 'Switzerland', flag: '🇨🇭', enabled: false),
    CountryCode(code: '+43', name: 'Austria', flag: '🇦🇹', enabled: false),
    CountryCode(code: '+32', name: 'Belgium', flag: '🇧🇪', enabled: false),
    CountryCode(code: '+46', name: 'Sweden', flag: '🇸🇪', enabled: false),
    CountryCode(code: '+47', name: 'Norway', flag: '🇳🇴', enabled: false),
    CountryCode(code: '+45', name: 'Denmark', flag: '🇩🇰', enabled: false),
    CountryCode(code: '+358', name: 'Finland', flag: '🇫🇮', enabled: false),
    CountryCode(code: '+351', name: 'Portugal', flag: '🇵🇹', enabled: false),
    CountryCode(code: '+30', name: 'Greece', flag: '🇬🇷', enabled: false),
    CountryCode(code: '+90', name: 'Turkey', flag: '🇹🇷', enabled: false),
    CountryCode(code: '+91', name: 'India', flag: '🇮🇳', enabled: false),
    CountryCode(code: '+86', name: 'China', flag: '🇨🇳', enabled: false),
    CountryCode(code: '+81', name: 'Japan', flag: '🇯🇵', enabled: false),
    CountryCode(code: '+82', name: 'South Korea', flag: '🇰🇷', enabled: false),
    CountryCode(code: '+61', name: 'Australia', flag: '🇦🇺', enabled: false),
    CountryCode(code: '+64', name: 'New Zealand', flag: '🇳🇿', enabled: false),
    CountryCode(code: '+27', name: 'South Africa', flag: '🇿🇦', enabled: false),
    CountryCode(code: '+55', name: 'Brazil', flag: '🇧🇷', enabled: false),
    CountryCode(code: '+52', name: 'Mexico', flag: '🇲🇽', enabled: false),
    CountryCode(code: '+54', name: 'Argentina', flag: '🇦🇷', enabled: false),
    CountryCode(code: '+56', name: 'Chile', flag: '🇨🇱', enabled: false),
    CountryCode(code: '+57', name: 'Colombia', flag: '🇨🇴', enabled: false),
    CountryCode(code: '+7', name: 'Russia', flag: '🇷🇺', enabled: false),
    CountryCode(code: '+380', name: 'Ukraine', flag: '🇺🇦', enabled: false),
    CountryCode(code: '+48', name: 'Poland', flag: '🇵🇱', enabled: false),
    CountryCode(code: '+420', name: 'Czech Republic', flag: '🇨🇿', enabled: false),
    CountryCode(code: '+36', name: 'Hungary', flag: '🇭🇺', enabled: false),
    CountryCode(code: '+40', name: 'Romania', flag: '🇷🇴', enabled: false),
    CountryCode(code: '+359', name: 'Bulgaria', flag: '🇧🇬', enabled: false),
    CountryCode(code: '+385', name: 'Croatia', flag: '🇭🇷', enabled: false),
    CountryCode(code: '+381', name: 'Serbia', flag: '🇷🇸', enabled: false),
    CountryCode(code: '+62', name: 'Indonesia', flag: '🇮🇩', enabled: false),
    CountryCode(code: '+60', name: 'Malaysia', flag: '🇲🇾', enabled: false),
    CountryCode(code: '+65', name: 'Singapore', flag: '🇸🇬', enabled: false),
    CountryCode(code: '+66', name: 'Thailand', flag: '🇹🇭', enabled: false),
    CountryCode(code: '+84', name: 'Vietnam', flag: '🇻🇳', enabled: false),
    CountryCode(code: '+63', name: 'Philippines', flag: '🇵🇭', enabled: false),
    CountryCode(code: '+20', name: 'Egypt', flag: '🇪🇬', enabled: false),
    CountryCode(code: '+971', name: 'UAE', flag: '🇦🇪', enabled: false),
    CountryCode(code: '+966', name: 'Saudi Arabia', flag: '🇸🇦', enabled: false),
    CountryCode(code: '+962', name: 'Jordan', flag: '🇯🇴', enabled: false),
    CountryCode(code: '+961', name: 'Lebanon', flag: '🇱🇧', enabled: false),
    CountryCode(code: '+212', name: 'Morocco', flag: '🇲🇦', enabled: false),
    CountryCode(code: '+216', name: 'Tunisia', flag: '🇹🇳', enabled: false),
    CountryCode(code: '+213', name: 'Algeria', flag: '🇩🇿', enabled: false),
  ];

  /// Get all country codes (including disabled ones)
  static List<CountryCode> get all => _allCountryCodes;

  /// Get only enabled country codes
  static List<CountryCode> get enabled => 
      _allCountryCodes.where((country) => country.enabled).toList();

  /// Get country codes as `Map<String, String>` format for compatibility
  /// Only returns enabled countries by default
  static List<Map<String, String>> get enabledAsMaps => 
      enabled.map((country) => {
        'code': country.code,
        'name': country.name,
        'flag': country.flag,
      }).toList();

  /// Get all country codes as `Map<String, String>` format
  static List<Map<String, String>> get allAsMaps => 
      all.map((country) => {
        'code': country.code,
        'name': country.name,
        'flag': country.flag,
      }).toList();

  /// Find a country by code
  static CountryCode? findByCode(String code) {
    try {
      return _allCountryCodes.firstWhere((country) => country.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Check if a country code is enabled
  static bool isCountryEnabled(String code) {
    final country = findByCode(code);
    return country?.enabled ?? false;
  }

  /// Get default country code (Israel in this case)
  static String get defaultCountryCode => '+972';

  /// Get default country
  static CountryCode get defaultCountry => 
      findByCode(defaultCountryCode) ?? enabled.first;
}