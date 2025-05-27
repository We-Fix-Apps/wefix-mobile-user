import 'package:flutter/material.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/model/realstate_model.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';

class AppartmentCardWidget extends StatefulWidget {
  final RealEstate? realEstate;
  const AppartmentCardWidget({super.key, this.realEstate});

  @override
  State<AppartmentCardWidget> createState() => _AppartmentCardWidgetState();
}

class _AppartmentCardWidgetState extends State<AppartmentCardWidget> {
  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const WidgetCachNetworkImage(
              image:
                  'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
              width: 50,
              height: 50,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
         
              const SizedBox(height: 6),
              Text(
                widget.realEstate?.title ?? "",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey),
                  SizedBox(width: 5),
                  SizedBox(
                    width: AppSize(context).width * 0.7,
                    child: Text(
                      widget.realEstate?.address ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: AppSize(context).smallText3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
