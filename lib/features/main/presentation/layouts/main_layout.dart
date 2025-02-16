import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/home_page.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/logs_page.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/records_page.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/settings_page.dart';

class MainLayout extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => MainLayout());

  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  List<String> routes = [
    "Home",
    "Records",
    "Logs",
    "Settings",
  ];

  List<Widget> pages = [
    const HomePage(),
    const RecordsPage(),
    const LogsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Container(
            height: deviceHeight * 0.12,
            width: deviceWidth,
            color: isDark
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.menu,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        height: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selectedIndex == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 4,
                            ),
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            routes[index],
                            style: TextStyle(
                              color: selectedIndex == index
                                  ? Theme.of(context).colorScheme.secondary
                                  : Colors.white60,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.025,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                IconButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withAlpha(64),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  icon: Icon(
                    FluentIcons.alert_24_filled,
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }
}
