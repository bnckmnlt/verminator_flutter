import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/food_waste/data/models/food_waste_model.dart';
import 'package:google_fonts/google_fonts.dart';

class SystemFoodWasteRecords extends StatefulWidget {
  final List<FoodWasteModel> foodWasteList;
  final void Function(int) imageSelector;

  const SystemFoodWasteRecords({
    super.key,
    required this.foodWasteList,
    required this.imageSelector,
  });

  @override
  State<SystemFoodWasteRecords> createState() => _SystemFoodWasteRecordsState();
}

class _SystemFoodWasteRecordsState extends State<SystemFoodWasteRecords> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 248,
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Kitchen Waste Records",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        width: 1,
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                      ),
                    ),
                    child: Text(
                      widget.foodWasteList.length.toString(),
                      style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.025),
                    ),
                  )
                ],
              ),
              // GestureDetector(
              //   onTap: () {
              //     setState(() {
              //       _currentItemLength =
              //           _currentItemLength == 36
              //               ? itemList.length
              //               : 36;
              //     });
              //   },
              //   child: Text(
              //     _currentItemLength != 36
              //         ? "View less"
              //         : "See all",
              //     style: TextStyle(
              //       color: Colors.blue,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 12,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: widget.foodWasteList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => widget.imageSelector(index),
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          width: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          widget.foodWasteList[index].filePath,
                          fit: BoxFit.contain,
                        ),
                      )),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
