import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class WidgetPhoneField extends StatefulWidget {
  final Function(PhoneNumber)? onCountryChanged;
  final TextEditingController? phoneController;
  final Function(String)? onFieldSubmitted;
  final Function()? onSubmit;
  final String? code;
  final String? message;
  final Function(String?)? validator;
  final String? hint;
  final Color? color;
  const WidgetPhoneField({
    super.key,
    required this.onCountryChanged,
    this.phoneController,
    this.validator,
    this.code,
    this.message,
    this.onFieldSubmitted,
    this.onSubmit,
    this.color,
    this.hint,
  });

  @override
  State<WidgetPhoneField> createState() => _WidgetPhoneFieldState();
}

class _WidgetPhoneFieldState extends State<WidgetPhoneField> {
  PhoneNumber number = PhoneNumber(isoCode: 'JO');
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.code != null) {
      if (mounted) {
        setState(() {
          number = PhoneNumber(isoCode: widget.code);
        });
      }
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: InternationalPhoneNumberInput(
        onSubmit: widget.onSubmit,
        // errorMessage: widget.hint != null ? null : widget.message ?? 'required',
        onFieldSubmitted: widget.onFieldSubmitted,

        keyboardAction: TextInputAction.next,
        hintText: widget.hint ?? 'XX XXXXXXX',
        textStyle: TextStyle(
          fontSize: AppSize(context).smallText1,
          color: AppColors.blackColor1,
        ),
        spaceBetweenSelectorAndTextField: 10,
        inputBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: BorderSide(color: AppColors(context).primaryColor),
            borderRadius: BorderRadius.circular(7)),
        inputDecoration: InputDecoration(
          fillColor: widget.color ?? AppColors.greyColorback,
          hintStyle: TextStyle(
            fontSize: widget.hint != null
                ? AppSize(context).mediumText4
                : AppSize(context).smallText2,
            color: widget.hint != null
                ? AppColors.blackColor1
                : AppColors.greyColor3,
          ),
          hintText: widget.hint ?? 'XX XXXXXXX',
          hintTextDirection: TextDirection.ltr,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          border: OutlineInputBorder(
              gapPadding: 0,
              borderSide: BorderSide(color: AppColors.backgroundColor),
              borderRadius: BorderRadius.circular(7)),
          focusedBorder: OutlineInputBorder(
              gapPadding: 0,
              borderSide: BorderSide(color: AppColors.backgroundColor),
              borderRadius: BorderRadius.circular(7)),
          disabledBorder: OutlineInputBorder(
              gapPadding: 0,
              borderSide: BorderSide(color: AppColors.backgroundColor),
              borderRadius: BorderRadius.circular(7)),
          enabledBorder: OutlineInputBorder(
              gapPadding: 0,
              borderSide: BorderSide(color: AppColors.backgroundColor),
              borderRadius: BorderRadius.circular(7)),
          errorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: const BorderSide(color: AppColors.redColor),
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        onInputChanged: widget.onCountryChanged,
        countries: const [
          'JO',
          'AE',
          'IQ',
          'SA',
          'QA',
          'PS',
          'PL',
          'AD',
          'AG',
          'AR',
          'AM',
          'AU',
          'AT',
          'AZ',
          'BS',
          'BH',
          'BD',
          'BB',
          'BY',
          'BE',
          'BZ',
          'BJ',
          'BT',
          'BO',
          'BA',
          'BW',
          'BR',
          'BN',
          'BG',
          'BF',
          'BI',
          'CV',
          'KH',
          'CM',
          'CA',
          'CF',
          'TD',
          'CL',
          'CN',
          'CO',
          'KM',
          'CG',
          'CD',
          'CR',
          'HR',
          'CU',
          'CY',
          'CZ',
          'DK',
          'DJ',
          'DM',
          'DO',
          'EC',
          'EG',
          'SV',
          'GQ',
          'ER',
          'EE',
          'ET',
          'FJ',
          'FI',
          'FR',
          'GA',
          'GM',
          'GE',
          'DE',
          'GH',
          'GR',
          'GD',
          'GT',
          'GN',
          'GW',
          'GY',
          'HT',
          'HN',
          'HU',
          'IN',
          'ID',
          'IR',
          'IE',
          'IT',
          'JM',
          'JP',
          'KZ',
          'KE',
          'KI',
          'KP',
          'KR',
          'KW',
          'KG',
          'LA',
          "PS",
          'LV',
          'LB',
          'LS',
          'LR',
          'LY',
          'LI',
          'LT',
          'LU',
          'MG',
          'MW',
          'MY',
          'MV',
          'ML',
          'MT',
          'MH',
          'MR',
          'MU',
          'MX',
          'FM',
          'MD',
          'MC',
          'MN',
          'ME',
          'MA',
          'MZ',
          'MM',
          'NA',
          'NR',
          'NP',
          'NL',
          'NZ',
          'NI',
          'NE',
          'NG',
          'MK',
          'NO',
          'OM',
          'PK',
          'PW',
          'PA',
          'PG',
          'PY',
          'PE',
          'PH',
          'PT',
          'RO',
          'RU',
          'RW',
          'KN',
          'LC',
          'VC',
          'WS',
          'SM',
          'ST',
          'SN',
          'RS',
          'SC',
          'SL',
          'SG',
          'SK',
          'SI',
          'SB',
          'SO',
          'ZA',
          'SS',
          'ES',
          'LK',
          'SD',
          'SR',
          'SZ',
          'SE',
          'CH',
          'SY',
          'TW',
          'TJ',
          'TZ',
          'TH',
          'TL',
          'TG',
          'TO',
          'TT',
          'TN',
          'TR',
          'TM',
          'TV',
          'UG',
          'UA',
          'GB',
          'US',
          'UY',
          'UZ',
          'VU',
          'VA',
          'VE',
          'VN',
          'YE',
          'ZM',
          'ZW'
        ],
        textAlignVertical: TextAlignVertical.center,
        selectorConfig: const SelectorConfig(
          trailingSpace: true,
          useEmoji: true,
          setSelectorButtonAsPrefixIcon: true,
          leadingPadding: 15,
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        ),
        searchBoxDecoration: InputDecoration(
          fillColor: AppColors.whiteColor1,
          hintStyle: TextStyle(
            fontSize: AppSize(context).smallText2,
            color: AppColors.greyColor3,
          ),
          hintText: "ابحث عن الدولة",
          suffixIcon: const Icon(Icons.search),
          hintTextDirection: TextDirection.rtl,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          border: OutlineInputBorder(
              gapPadding: 0,
              borderSide: const BorderSide(color: AppColors.greyColor3),
              borderRadius: BorderRadius.circular(7)),
          focusedBorder: OutlineInputBorder(
              gapPadding: 0,
              borderSide: const BorderSide(color: AppColors.greyColor3),
              borderRadius: BorderRadius.circular(7)),
          disabledBorder: OutlineInputBorder(
              gapPadding: 0,
              borderSide: const BorderSide(color: AppColors.greyColor3),
              borderRadius: BorderRadius.circular(7)),
          enabledBorder: OutlineInputBorder(
              gapPadding: 0,
              borderSide: const BorderSide(color: AppColors.greyColor3),
              borderRadius: BorderRadius.circular(7)),
          errorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: const BorderSide(color: AppColors.redColor),
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        ignoreBlank: true,
        autoValidateMode: AutovalidateMode.onUserInteraction,
        initialValue: number,
        validator: widget.validator as String? Function(String?)?,

        textFieldController: widget.phoneController,
        formatInput: false,
        maxLength: 14,
        keyboardType:
            const TextInputType.numberWithOptions(signed: true, decimal: true),
      ),
    );
  }
}
