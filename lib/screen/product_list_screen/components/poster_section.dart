import '../../../core/data/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utility/app_data.dart';

class PosterSection extends StatelessWidget {
  const PosterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: dataProvider.posters.length,
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: AppData.randomPosterBgColors[index],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        // Wrap with Expanded
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                // Add Flexible for text
                                child: Text(
                                  '${dataProvider.posters[index].posterName}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              // Removed the "Get Now" button
                            ],
                          ),
                        ),
                      ),
                      ClipRRect(
                        // Wrap image with ClipRRect
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                          width: 120, // Fixed width for image
                          child: Image.network(
                            '${dataProvider.posters[index].imageUrl}',
                            height: 125,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child:
                                    const Icon(Icons.error, color: Colors.red),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
