import 'package:day_night/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'splash_screen.dart';
import 'app_localizations.dart';
import 'tabs/home_tab.dart';
import 'tabs/search_tab.dart';
import 'tabs/ticket_tab.dart';
import 'tabs/editing_tab.dart';
import 'services/category_repository.dart';
import 'services/language_service.dart';
import 'services/event_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> setAppLanguageIdByDeviceLocale() async {
  final languages = await LanguageService().getLanguages();
  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  final deviceLangCode = deviceLocale.languageCode;
  final match = languages.firstWhere(
    (lang) => lang.code == deviceLangCode,
    orElse: () => languages.firstWhere((lang) => lang.code == 'en', orElse: () => languages.first),
  );
  kAppLanguageId = match.id;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Your existing initialization
  await setAppLanguageIdByDeviceLocale();
  await CategoryRepository().loadCategories();

  // Wrap your app with ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('he'),
      ],
      home: const SplashScreenWrapper(),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final eventService = EventService();
    // Pre-fetch initial data
    await Future.wait([
      eventService.getEventsByDate('today'),
      eventService.getEventsByDate('week'),
    ]);
    
    // Add a minimum splash screen duration
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    } else {
      return MyHomePage(title: AppLocalizations.of(context).get('day_night_home'));
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // Already exists

  static const List<Widget> _pages = <Widget>[
    HomeTab(),
    SearchTab(),
    TicketTab(),
    EditingTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.black, // Set your desired background color here
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // Keep transparent, use parent Container color
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            _buildBarItem(
              'assets/images/home_icon.svg',
              0,
              context,
            ),
            _buildBarItem(
              'assets/images/search_icon.svg',
              1,
              context,
            ),
            _buildBarItem(
              'assets/images/events_icon.svg',
              2,
              context,
            ),
            _buildBarItem(
              'assets/images/create_icon.svg',
              3,
              context,
            ),
          ],
        ),
      ),
      floatingActionButton: null,
    );
  }


  BottomNavigationBarItem _buildBarItem(String asset, int index, BuildContext context) {
    final bool isActive = _selectedIndex == index; // This will work since _selectedIndex is defined in the class
    final Color activeColor = kBrandPrimary;
    final Color inactiveColor = kBrandPrimaryInvert;
    final Color bgColor = isActive ? activeColor : inactiveColor;

    return BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          asset,
          width: 36,
          height: 36,

        ),
      ),
      label: '',
    );
  }
}



class LocalizedText extends StatelessWidget {
  final String keyName;
  const LocalizedText(this.keyName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).get(keyName),
      style: const TextStyle(fontSize: 24),
      textDirection: Directionality.of(context),
    );
  }
}
