import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/realstate_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/empty_screen.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Profile/Components/appartments_widget.dart';
import 'package:wefix/Presentation/Profile/Screens/add_proparity_screen.dart';

class ApartmentScreen extends StatefulWidget {
  final String status;
  final Color statusColor;

  const ApartmentScreen({
    super.key,
    required this.status,
    required this.statusColor,
  });

  @override
  State<ApartmentScreen> createState() => _ApartmentScreenState();
}

bool? loading = false;
RealEstatesModel? realEstatesModel;

class _ApartmentScreenState extends State<ApartmentScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRealState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText(context).myProperty),
        centerTitle: true,
        actions: const [LanguageButton()],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: CustomBotton(
          title: AppText(context).addProperty,
          onTap: () async {
            final a = await Navigator.push(
                context, rightToLeft(AddRealStateScreen()));

            if (a) {
              getRealState();
            }
          },
        ),
      ),
      body: loading == true
          ? LinearProgressIndicator(
              color: AppColors(context).primaryColor,
              backgroundColor: AppColors.secoundryColor,
            )
          : realEstatesModel?.realEstates.isEmpty == true
              ? EmptyScreen()
              : ListView.separated(
                  itemCount: realEstatesModel?.realEstates.length ?? 0,
                  padding: const EdgeInsets.all(8),
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 5,
                    );
                  },
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          rightToLeft(
                            AddRealStateScreen(
                              isFromEdit: true,
                              title:
                                  '${realEstatesModel?.realEstates[index].title}',
                              address:
                                  '${realEstatesModel?.realEstates[index].address}',
                              apartmentNo:
                                  '${realEstatesModel?.realEstates[index].apartmentNo}',
                              latitude:
                                  '${realEstatesModel?.realEstates[index].latitude}',
                              longitude:
                                  '${realEstatesModel?.realEstates[index].longitude}',
                              id: realEstatesModel?.realEstates[index].id ?? 0,
                            ),
                          ),
                        );
                      },
                      child: AppartmentCardWidget(
                        realEstate: realEstatesModel?.realEstates[index],
                      ),
                    );
                  },
                ),
    );
  }

  Future getRealState() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    await ProfileApis.getRealState(
      token: '${appProvider.userModel?.token}',
    ).then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            loading = false;
            realEstatesModel = value;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }
    });
  }
}
