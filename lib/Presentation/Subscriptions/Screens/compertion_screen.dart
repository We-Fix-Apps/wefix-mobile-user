import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/packages_model.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';

class ComparisonScreen extends StatelessWidget {
  final List<PackagePackage> plans;
  const ComparisonScreen({super.key, required this.plans});

  @override
  Widget build(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: true);
    final appText = AppText(context);
    final primaryColor = AppColors(context).primaryColor;

    final comparisonFields = [
      {
        'key': 'numberOfUrgentVisits',
        'label': languageProvider.lang == 'ar'
            ? '🚨 الزيارات الطارئة'
            : '🚨 Urgent Visits'
      },
      {
        'key': 'numberOfRegularVisit',
        'label': languageProvider.lang == 'ar'
            ? '🧾 الزيارات العادية'
            : '🧾 Regular Visits'
      },
      {
        'key': 'numberOnDemandVisit',
        'label': languageProvider.lang == 'ar'
            ? '📞 زيارات عند الطلب'
            : '📞 On-Demand Visits'
      },
      {
        'key': 'numberOfFemalUse',
        'label': languageProvider.lang == 'ar'
            ? '👩‍🔧 الخدمة النسائية'
            : '👩‍🔧 Female Services'
      },
      {
        'key': 'consultation',
        'label':
            languageProvider.lang == 'ar' ? '💬 الاستشارات' : '💬 Consultation'
      },
      {
        'key': 'interiorDesign',
        'label': languageProvider.lang == 'ar'
            ? '🎨 تصميم داخلي'
            : '🎨 Interior Design'
      },
      {
        'key': 'discount',
        'label':
            languageProvider.lang == 'ar' ? '🏷️ الخصم' : '🏷️ Discount (%)'
      },
      {
        'key': 'totalvisit',
        'label': languageProvider.lang == 'ar'
            ? '📊 إجمالي الزيارات'
            : '📊 Total Visits'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appText.comparePlans,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: const [LanguageButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: SizedBox()),
                  ...plans.map((plan) => Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                plan.title ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppSize(context).smallText1,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${plan.price} ${appText.jod} ${appText.jODMonth}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                children: comparisonFields.map((field) {
                  final label = field['label']!;
                  final key = field['key']!;
                  final values = plans.map((p) => getRawValue(p, key)).toList();
                  final numericValues =
                      values.map((v) => getNumericForComparison(v)).toList();
                  final maxValue =
                      numericValues.reduce((a, b) => a > b ? a : b);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: AppSize(context).smallText3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ...values.asMap().entries.map((entry) {
                          final index = entry.key;
                          final value = entry.value;
                          final numeric = numericValues[index];

                          return Expanded(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: numeric == maxValue && maxValue != 0
                                      ? primaryColor.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  getValueDisplay(value, key),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: numeric == maxValue && maxValue != 0
                                        ? primaryColor
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets the raw value from the JSON
  dynamic getRawValue(PackagePackage plan, String key) {
    try {
      return plan.toJson()[key];
    } catch (_) {
      return null;
    }
  }

  /// Converts raw value to a display string with formatting
  String getValueDisplay(dynamic value, String key) {
    if (value == null) return "-";

    if (value is bool) return value ? "✅" : "❌";

    if (value is int || value is double) {
      if (key == "discount" || key == "الخصم") {
        return "$value%";
      }
      return "$value";
    }

    String stringValue = value.toString().toLowerCase();
    if (["yes", "true", "1"].contains(stringValue)) return "✅";
    if (["no", "false", "0"].contains(stringValue)) return "❌";

    return stringValue;
  }

  /// Converts value to numeric for comparison logic
  int getNumericForComparison(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();

    String stringValue = value.toString().toLowerCase();
    if (["yes", "true", "1"].contains(stringValue)) return 1;
    if (["no", "false", "0"].contains(stringValue)) return 0;

    return 0;
  }
}
