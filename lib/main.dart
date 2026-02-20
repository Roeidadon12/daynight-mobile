import 'package:day_night/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'utils/logger.dart';
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
import 'package:provider/provider.dart';
import 'providers/search_provider.dart';
import 'controllers/user/user_controller.dart';

Future<void> setAppLanguageIdByDeviceLocale() async {
  try {
    final languages = await LanguageService().getLanguages();
    if (languages.isEmpty) {
      Logger.warning('No languages available, using default language ID', 'Main');
      return;
    }
    
    // Store languages globally for app-wide access
    kAppLanguages = languages;
    Logger.info('Stored ${kAppLanguages.length} languages globally', 'Main');
    
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final deviceLangCode = deviceLocale.languageCode;
    final match = languages.firstWhere(
      (lang) => lang.code == deviceLangCode,
      orElse: () => languages.firstWhere((lang) => lang.code == 'en', orElse: () => languages.first),
    );
    kAppLanguageId = match.id;
  } catch (e) {
    Logger.error('Failed to set app language: $e', 'Main');
    // Keep the default language ID from config
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Your existing initialization
  await setAppLanguageIdByDeviceLocale();
  await CategoryRepository().loadAllCategories();

  // Wrap your app with ProviderScope for Riverpod
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SearchProvider>.value(value: SearchProvider()),
        ChangeNotifierProvider<UserController>(create: (_) => UserController()),
      ],
      child: const MyApp(),
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
        FlutterQuillLocalizations.delegate,
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
    // Defer initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final eventService = EventService();
    
    // Initialize user authentication status
    final userController = Provider.of<UserController>(context, listen: false);
    
    // Pre-fetch initial data and initialize user controller
    await Future.wait([
      eventService.getEventsByDate('today'),
      eventService.getEventsByDate('week'),
      userController.initialize(), // Initialize user authentication state
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
  int _selectedIndex = 0;

  List<Widget> _getPages(bool isLoggedIn) {
    if (isLoggedIn) {
      return [
        const HomeTab(),
        const SearchTab(),
        const TicketTab(),
        const EditingTab(),
      ];
    } else {
      // Guest users don't see the TicketTab
      return [
        const HomeTab(),
        const SearchTab(),
        const EditingTab(),
      ];
    }
  }

  void _onItemTapped(int index, bool isLoggedIn) {
    setState(() {
      if (!isLoggedIn && index >= 2) {
        // For guest users, adjust index since TicketTab is not present
        // Index 2 becomes EditingTab instead of TicketTab
        _selectedIndex = index;
      } else {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, _) {
        final isLoggedIn = userController.isLoggedIn;
        final pages = _getPages(isLoggedIn);
        
        // Ensure selected index doesn't exceed available pages
        if (_selectedIndex >= pages.length) {
          _selectedIndex = 0;
        }
        
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            color: Colors.black,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              currentIndex: _selectedIndex,
              onTap: (index) => _onItemTapped(index, isLoggedIn),
              items: _buildBottomNavItems(isLoggedIn, context),
            ),
          ),
          floatingActionButton: null,
        );
      },
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavItems(bool isLoggedIn, BuildContext context) {
    final items = [
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
    ];
    
    if (isLoggedIn) {
      // Add My Tickets tab for logged in users
      items.add(_buildBarItem(
        'assets/images/events_icon.svg',
        2,
        context,
      ));
      items.add(_buildBarItem(
        'assets/images/create_icon.svg',
        3,
        context,
      ));
    } else {
      // For guest users, skip My Tickets and go straight to Create
      items.add(_buildBarItem(
        'assets/images/create_icon.svg',
        2,
        context,
      ));
    }
    
    return items;
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
