import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'pages/meters_page.dart';
import 'pages/trends_page.dart';
import 'pages/history_page.dart';
import 'pages/settings_page.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';

/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
/// In that case, remove them after copying this theme to your
/// app or upgrade package to version 8.0.2.
///
/// Use in [MaterialApp] like this:
///
/// MaterialApp(
///  theme: AppTheme.light,
///  darkTheme: AppTheme.dark,
///  :
/// );
sealed class AppTheme {
  // Light theme
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.mango,
    appBarStyle: FlexAppBarStyle.material, // AppBar style
    appBarBackground: Color(0xFF8D9440), // AppBar background color
    subThemesData: const FlexSubThemesData(
      navigationBarBackgroundSchemeColor:
          SchemeColor.primary, // NavigationBar background
      navigationBarMutedUnselectedLabel: true,
      navigationBarMutedUnselectedIcon: true,
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  // Dark theme
  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.mango,
    appBarStyle: FlexAppBarStyle.material, // AppBar style
    appBarBackground: FlexColor.materialDarkSurface, // AppBar background color
    subThemesData: const FlexSubThemesData(
      navigationBarBackgroundSchemeColor:
          SchemeColor.primary, // NavigationBar background
      navigationBarMutedUnselectedLabel: true,
      navigationBarMutedUnselectedIcon: true,
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create the SettingsProvider and load the settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    ChangeNotifierProvider(
      create: (_) => settingsProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    MetersPage(),
    HistoryPage(),
    TrendsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeaverMeter',
      theme: AppTheme.light,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF8D9440), //)),
          // backgroundColor: const Color.fromARGB(255, 122, 176, 184),
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          // backgroundColor: Colors.blue,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.electric_meter),
              label: 'Meters',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Trends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          // selectedItemColor: const Color.fromARGB(255, 122, 176, 184),
          // unselectedItemColor: const Color.fromARGB(255, 201, 201, 201),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
