import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';

class RatingModal extends StatefulWidget {
  final int id;
  final bool isRated ;

  const RatingModal({super.key, required this.id, required this.isRated});
  @override
  _RatingModalState createState() => _RatingModalState();
}

class _RatingModalState extends State<RatingModal> {
  double rating = 4.0;
  bool loading = false;
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppText(context, isFunction: true).ratethevendor,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              AppText(context, isFunction: true).serviceFeedback,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 5),
            Text(
                AppText(context, isFunction: true)
                    .pleaserateyourexperiencebelow,
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => SvgPicture.asset(
                'assets/icon/favorite.svg',
                height: 20,
                width: 20,
              ),
              onRatingUpdate: (newRating) {
                setState(() {
                  rating = newRating;
                });
              },
            ),
            const SizedBox(height: 5),
            Text('${rating.toString()}/5 stars',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            WidgetTextField(
                AppText(context, isFunction: true).additionalfeedback,
                controller: commentController),
            const SizedBox(height: 20),
            CustomBotton(
              loading: loading,
              title: "${AppText(context, isFunction: true).ratethevendor}",
              onTap: () {
                addRate();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addRate() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    final value = await ProfileApis.addReviewTech(
      token: '${appProvider.userModel?.token}',
      comment: commentController.text,
      rate: rating,
      id: widget.id,
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (value == true) {
      pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppText(context, isFunction: true).successfully,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Optionally show error Snackbar here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add rating.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
