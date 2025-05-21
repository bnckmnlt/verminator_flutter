import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/home_page.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/logs_page.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/records_page.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_page.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/settings_page.dart';

class NavigationItem {
  final String title;
  final Widget page;

  const NavigationItem({required this.title, required this.page});
}

class MainLayout extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const MainLayout());
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  static const double _headerHeightFactor = 0.12;
  static const double _tabFontSize = 16.0;
  static const double _tabBorderWidth = 4.0;
  static const double _alertIconSize = 20.0;
  static const EdgeInsets _headerPadding = EdgeInsets.fromLTRB(16, 24, 16, 0);
  static const EdgeInsets _tabPadding = EdgeInsets.all(8);

  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(title: "Home", page: HomePage()),
    NavigationItem(title: "Schedule", page: SchedulePage()),
    NavigationItem(title: "Records", page: RecordsPage()),
    NavigationItem(title: "Logs", page: LogsPage()),
    NavigationItem(title: "Settings", page: SettingsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          _buildHeader(context, deviceHeight, deviceWidth, isDarkMode),
          Expanded(
            child: _navigationItems[_selectedIndex].page,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, double height, double width, bool isDarkMode) {
    return Container(
      height: height * _headerHeightFactor,
      width: width,
      color: isDarkMode
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.onSurface,
      padding: _headerPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMenuIcon(context),
          _buildNavigationTabs(context),
          _buildAlertButton(context),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _navigationItems.length,
        (index) => _NavigationTab(
          title: _navigationItems[index].title,
          isSelected: _selectedIndex == index,
          onTap: () => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }

  Widget _buildMenuIcon(BuildContext context) {
    return Icon(
      Icons.menu,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildAlertButton(BuildContext context) {
    return IconButton(
      onPressed: () {},
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(64),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      icon: Icon(
        FluentIcons.alert_24_filled,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        size: _alertIconSize,
      ),
    );
  }
}

class _NavigationTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        padding: _MainLayoutState._tabPadding,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: _MainLayoutState._tabBorderWidth,
            ),
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.white60,
              fontSize: _MainLayoutState._tabFontSize,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.025,
            ),
          ),
        ),
      ),
    );
  }
}
