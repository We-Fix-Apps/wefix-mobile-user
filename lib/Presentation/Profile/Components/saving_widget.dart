import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';

class SavingCard extends StatelessWidget {
  final double savingsAmount;
  final double goalAmount;

  const SavingCard({
    super.key,
    required this.savingsAmount,
    required this.goalAmount,
  });

  @override
  Widget build(BuildContext context) {
    double progress = savingsAmount / goalAmount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors(context).primaryColor, Colors.orange.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Savings Icon
            Image.asset(
              "assets/image/saving.png",
              height: AppSize(context).height * .12,
              width: AppSize(context).height * .12,
            ),
            const SizedBox(width: 20),
            // Savings Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText(context).savingsThisYear,
                  style: TextStyle(
                    fontSize: AppSize(context).smallText2,
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "JOD ${savingsAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                // Progress Bar
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: AppColors.whiteColor1,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: progress > 1 ? 1.0 : progress,
                      backgroundColor: AppColors.greyColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.secoundryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${(progress * 100).toStringAsFixed(0)}% ${AppText(context).ofyourgoal}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.whiteColor1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
