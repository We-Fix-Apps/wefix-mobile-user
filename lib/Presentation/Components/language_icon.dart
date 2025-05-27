import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/l10n/l10n.dart';

class LanguageButton extends StatefulWidget {
  const LanguageButton({super.key});

  @override
  State<LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<LanguageButton> {
  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);

    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          log(languageProvider.lang.toString());
          if (languageProvider.lang == "ar") {
            setState(() {
              appProvider.setLanguae("en");
              languageProvider.setLocal(locale: const Locale("en"));
            });
          } else {
            setState(() {
              appProvider.setLanguae("ar");

              languageProvider.setLocal(locale: const Locale("ar"));
            });
          }
        },
        child: const Text(
          "EN/AR",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
