import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/error_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphic_card_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/status_card_widget.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_initialization_widgets/list_item_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class InitializationSuccessScreen extends StatefulWidget {
  const InitializationSuccessScreen({super.key});

  @override
  State<InitializationSuccessScreen> createState() =>
      _InitializationSuccessScreenState();
}

class _InitializationSuccessScreenState
    extends State<InitializationSuccessScreen> {
  final List<ClassListItem> validMaterials = const [
    ClassListItem(
      icon: FluentIcons.food_apple_24_regular,
      text: "Fruits_5123512.jpg",
      iconColor: Colors.indigo,
    ),
    ClassListItem(
      icon: FluentIcons.food_apple_24_regular,
      text: "Vegetable_23232362.jpg",
      iconColor: Colors.green,
    ),
    ClassListItem(
      icon: FluentIcons.food_apple_24_regular,
      text: "Vegetable_736234.jpg",
      iconColor: Colors.green,
    ),
    ClassListItem(
      icon: FluentIcons.food_apple_24_regular,
      text: "Grain_2342623.jpg",
      iconColor: Colors.amber,
    ),
    ClassListItem(
      icon: FluentIcons.food_apple_24_regular,
      text: "Fruits_482341.jpg",
      iconColor: Colors.indigo,
    ),
    ClassListItem(
      icon: FluentIcons.food_apple_24_regular,
      text: "Grain_981300.jpg",
      iconColor: Colors.amber,
    ),
  ];

  final List<ClassListItem> invalidMaterials = const [
    ClassListItem(
      icon: FluentIcons.prohibited_24_regular,
      text: "Invalid_5123512.jpg",
      iconColor: Colors.red,
    ),
    ClassListItem(
      icon: FluentIcons.prohibited_24_regular,
      text: "Invalid_23232362.jpg",
      iconColor: Colors.red,
    ),
    ClassListItem(
      icon: FluentIcons.prohibited_24_regular,
      text: "Invalid_736234.jpg",
      iconColor: Colors.red,
    ),
    ClassListItem(
      icon: FluentIcons.prohibited_24_regular,
      text: "Invalid_4826712.jpg",
      iconColor: Colors.red,
    ),
  ];

  final List<ConfigInformation> _configInfoList = [
    ConfigInformation(label: "Ambient Fan", setting: "30°C : 80%"),
    ConfigInformation(label: "Soil Misture", setting: "40°C - 60%"),
    ConfigInformation(label: "Soil Aeration", setting: "60°C - 80%"),
    ConfigInformation(label: "Feeding Reminder", setting: "7 Days"),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double deviceHeight = MediaQuery.of(context).size.height;
      final double deviceWidth = MediaQuery.of(context).size.width;
      final bool isDarkMode =
          MediaQuery.of(context).platformBrightness == Brightness.dark;

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<FoodWasteBloc, FoodWasteState>(
                  builder: (context, state) {
                if (state is FoodWasteLoading) {
                  return const Loader();
                } else if (state is FoodWasteFailure) {
                  return Center(
                    child: GeneralErrorWidget(
                      errorTitle: "An error has occurred during fetching",
                      errorMessage: state.error,
                    ),
                  );
                } else if (state is FoodWasteListSuccess) {
                  final invalidData = state.foodWaste
                      .where((item) =>
                          item.foodWasteScheduleId == 1 &&
                          item.classname == FoodWasteClassname.invalid)
                      .map((item) {
                    return FoodWasteClass(
                      pathname: item.filePath,
                      icon: getClassnameIconData(item.classname),
                      classname: item.classname,
                      color: Colors.redAccent,
                    );
                  }).toList();

                  final validData = state.foodWaste
                      .where((item) =>
                          item.foodWasteScheduleId == 1 &&
                          item.classname != FoodWasteClassname.invalid)
                      .map((item) {
                    return FoodWasteClass(
                      pathname: item.filePath,
                      icon: getClassnameIconData(item.classname),
                      classname: item.classname != FoodWasteClassname.invalid
                          ? item.classname
                          : FoodWasteClassname.invalid,
                      color: Colors.greenAccent,
                    );
                  }).toList();

                  return Expanded(
                    child: GlassmorphicCardWidget(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _summaryHeaderSection(),
                          _materialsValidatedSection(validData, invalidData),
                          const SizedBox(height: 32),
                          _configurationSection(),
                          const SizedBox(height: 32),
                          _configInfoSection(),
                        ],
                      ),
                    ),
                  );
                }

                return SizedBox();
              }),
              const SizedBox(width: 24),
              Expanded(
                child: StatusCardWidget(
                  iconSrc: 'assets/animations/success-animate.json',
                  title: "Successfully saved!",
                  message:
                      "System configuration complete and ready for vermiculture operations",
                  buttonLabel: "RETURN TO HOME",
                  buttonColor: Colors.blueAccent,
                  buttonBehavior: () {},
                  deviceHeight: deviceHeight,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _summaryHeaderSection() {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Summary",
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.025,
                ),
              ),
              const SizedBox(width: 6),
              Badge(
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                backgroundColor: Colors.amberAccent.withAlpha(44),
                label: Text(
                  "ID - 1",
                  style: GoogleFonts.notoSans(
                    color: Colors.amber,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _materialsValidatedSection(
    List<FoodWasteClass> validData,
    List<FoodWasteClass> invalidData,
  ) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 65,
                height: 40,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.lightBlueAccent.withAlpha(44),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: const Glassmorphism(
                            blur: 20,
                            opacity: 0.2,
                            child: Center(
                              child: Icon(
                                FluentIcons.food_20_regular,
                                color: Colors.lightBlueAccent,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 25,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent.withAlpha(44),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: const Glassmorphism(
                            blur: 20,
                            opacity: 0.2,
                            child: Center(
                              child: Icon(
                                FluentIcons.prohibited_multiple_24_regular,
                                color: Colors.redAccent,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Materials loaded and validated",
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.025,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _classList(validData),
                const SizedBox(width: 20),
                _classList(invalidData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _configurationSection() {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white60.withAlpha(44),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: const Glassmorphism(
                    blur: 20,
                    opacity: 0.2,
                    child: Center(
                      child: Icon(
                        FluentIcons.settings_24_regular,
                        color: Colors.white60,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Configurations",
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.025,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 16,
              childAspectRatio: 2.8,
              children: _configInfoList.map((item) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.setting,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.025,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(124),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.025,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _classList(List<FoodWasteClass> items) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
        child: items.length != 0
            ? ListView.builder(
                itemCount: items.length,
                shrinkWrap: true,
                itemBuilder: (_, index) => ClassListItem(
                  icon: items[index].icon,
                  text: items[index].pathname.split("/").last,
                  iconColor: items[index].color,
                ),
              )
            : Center(
                child: EmptyDisplayWidget(
                    title: "No results found",
                    description: "No invalid data has been found"),
              ),
      ),
    );
  }

  Widget _configInfoSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.surfaceContainerHigh),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Text(
        "Initial configuration uses recommended defaults. All parameters can be modified post-setup.",
        style: GoogleFonts.manrope(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 12,
          letterSpacing: 0.025,
        ),
      ),
    );
  }
}

class FoodWasteClass {
  final String pathname;
  final IconData icon;
  final FoodWasteClassname classname;
  final Color color;

  FoodWasteClass({
    required this.pathname,
    required this.icon,
    required this.classname,
    required this.color,
  });
}

IconData getClassnameIconData(FoodWasteClassname classname) {
  IconData iconData;

  switch (classname) {
    case FoodWasteClassname.fruit:
      iconData = FluentIcons.food_apple_24_regular;
    case FoodWasteClassname.vegetable:
      iconData = FluentIcons.plant_grass_24_regular;
    case FoodWasteClassname.grain:
      iconData = FluentIcons.food_20_regular;
    case FoodWasteClassname.invalid:
      iconData = FluentIcons.prohibited_24_regular;
  }

  return iconData;
}
