import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/appText/appText.dart';

class MaintenanceStepper extends StatelessWidget {
  final int currentStep; // 0-based index
  final String? confirmationNote; // 'With Approval' or 'Without Approval'

  const MaintenanceStepper({super.key, 
    required this.currentStep,
    this.confirmationNote,
  });

  @override
  Widget build(BuildContext context) {
    final bool withoutApproval = confirmationNote == 'Without Approval';

    // Base steps without the two conditional ones
    final List<_StepData> baseSteps = [
      // _StepData(AppText(context).requestRegistered,
      //     Icons.assignment_turned_in_outlined),
      // _StepData(AppText(context).visitScheduled, Icons.calendar_today_outlined),
      _StepData(AppText(context).readytoVisit, Icons.directions_run_outlined),
      _StepData(AppText(context).visitCompleted, Icons.check_circle_outline),
      _StepData(AppText(context).awaitingRating, Icons.star_outline),
    ];

    // The two conditional steps if with approval
    final List<_StepData> approvalSteps = [
      _StepData(AppText(context).preparingMaterials, Icons.inventory_outlined),
      _StepData(
        AppText(context).waitingforConfirmation,
        Icons.question_answer_outlined,
        subLabel: confirmationNote,
      ),
    ];

    // Final steps list depends on confirmationNote
    final List<_StepData> steps = withoutApproval
        ? [baseSteps[0]] + baseSteps.sublist(1) // skip approvalSteps
        : [baseSteps[0]] + approvalSteps + baseSteps.sublist(1);

    // Now build your Row widget using this `steps` list as before...
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(steps.length, (index) {
            final isCompleted = index < currentStep;
            final isActive = index == currentStep;
            final step = steps[index];

            return Row(
              children: [
                if (index != 0)
                  Container(
                    width: 30,
                    height: 2,
                    color: isCompleted
                        ? AppColors(context).primaryColor
                        : AppColors.secoundryColor,
                  ),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: isCompleted || isActive
                          ? AppColors(context).primaryColor
                          : AppColors.secoundryColor,
                      radius: 18,
                      child: Icon(
                        step.icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 90,
                      child: Column(
                        children: [
                          Text(
                            step.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: isCompleted || isActive
                                  ? Colors.black
                                  : Colors.grey,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (step.subLabel != null)
                            Text(
                              step.subLabel!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (index == steps.length - 1) const SizedBox(width: 10),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _StepData {
  final String label;
  final IconData icon;
  final String? subLabel;

  _StepData(this.label, this.icon, {this.subLabel});
}
