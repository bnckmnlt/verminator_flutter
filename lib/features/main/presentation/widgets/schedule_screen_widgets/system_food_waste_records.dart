import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/food_waste/data/models/food_waste_model.dart';
import 'package:galleryimage/galleryimage.dart';
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

const String _sectionTitle = "Kitchen Waste Records";

class _SystemFoodWasteRecordsState extends State<SystemFoodWasteRecords> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(context),
        GridView.builder(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: 8,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                if (index == 7) {
                } else {
                  widget.imageSelector(index);
                }
              },
              child: index >= 7
                  ? Container(
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
                        child: GalleryImage(
                          crossAxisCount: 1,
                          titleGallery: _sectionTitle,
                          numOfShowImages: 1,
                          imageUrls: widget.foodWasteList
                              .sublist(index, widget.foodWasteList.length)
                              .map((e) => e.filePath)
                              .toList(),
                        ),
                      ),
                    )
                  : Container(
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
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _sectionTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            _buildCounterBadge(context),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
      ),
      child: Text(
        widget.foodWasteList.length.toString(),
        style: GoogleFonts.spaceMono(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.025,
        ),
      ),
    );
  }
}
