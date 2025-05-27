import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/packages_model.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';

class ComparisonScreen extends StatelessWidget {
  final List<PackagePackage> plans;

  const ComparisonScreen({super.key, required this.plans});

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: true);

    final features = <String>{};

    for (var plan in plans) {
      for (var feature in plan.features) {
        features.add(languageProvider.lang == "ar"
            ? feature.featureAr ?? ""
            : feature.feature ?? "");
      }
    }

    final primaryColor = AppColors(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        actions: [const LanguageButton()],
        title: Text("${AppText(context).comparePlans}"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Plan Titles & Prices
              Row(
                children: plans
                    .map((plan) => Expanded(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  plan.title ?? "",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                plan.price.toString(),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 24),

              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppText(context).feature,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "Plan 1",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "Plan 2",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 8),

              // Features Comparison
              Expanded(
                child: ListView.separated(
                  itemCount: features.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, index) {
                    final featureName = features.elementAt(index);
                    return Row(
                      children: [
                        // Feature Name
                        Expanded(
                          child: Text(
                            featureName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        // Plan 1
                        Expanded(
                          child: Center(
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: getFeatureStatus(
                                      plans[0], featureName, context)
                                  ? Colors.green
                                  : Colors.red,
                              child: Icon(
                                getFeatureStatus(plans[0], featureName, context)
                                    ? Icons.check
                                    : Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        // Plan 2
                        Expanded(
                          child: Center(
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: getFeatureStatus(
                                      plans[1], featureName, context)
                                  ? Colors.green
                                  : Colors.red,
                              child: Icon(
                                getFeatureStatus(plans[1], featureName, context)
                                    ? Icons.check
                                    : Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool getFeatureStatus(PackagePackage plan, String featureName, context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: true);
    for (var feature in plan.features) {
      if ((languageProvider.lang == "ar"
              ? feature.featureAr ?? ""
              : feature.feature ?? "") ==
          featureName) return feature.status ?? false;
    }
    return false;
  }
}
