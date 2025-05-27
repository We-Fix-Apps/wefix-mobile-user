import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Reviews/reviews_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/questions_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Profile/Components/list_rate_type_widget.dart';

class MultiRateSheet extends StatefulWidget {
  final QuestionsModel? questionsModel;

  const MultiRateSheet({super.key, this.questionsModel});

  @override
  State<MultiRateSheet> createState() => _MultiRateSheetState();
}

class _MultiRateSheetState extends State<MultiRateSheet>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _animateStepOne = false;

  String? selectedSvgPath;
  Color? selectedColor;

  TextEditingController desc = TextEditingController();
  TextEditingController phone = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _animateStepOne = true;
      });
    });
  }

  void nextPage() {
    if (_currentPage < 3) {
      setState(() {
        _currentPage++;
        _animateStepOne = false;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_currentPage == 0) {
          setState(() => _animateStepOne = true);
        }
      });
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _animateStepOne = false;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_currentPage == 0) {
          setState(() => _animateStepOne = true);
        }
      });
    }
  }

  var key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: key,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.whiteColor1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      final answers =
                          context.read<AppProvider>().selectedAnswers;
                      // Use the `answers` list as needed
                      print(answers);
                      setState(() {
                        _currentPage = index;
                        _animateStepOne = index == 0;
                      });
                    },
                    children: [
                      stepOne(context),
                      stepTwo(
                        context,
                        image: selectedSvgPath,
                        iconColor: selectedColor,
                      ),
                      stepThree(context),
                      thankYouPage(context),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0 && _currentPage < 3)
                      CustomBotton(
                        title: AppText(context, isFunction: true).back,
                        onTap: previousPage,
                        width: AppSize(context).width * 0.2,
                        height: AppSize(context).height * 0.045,
                        color: AppColors.whiteColor1,
                        border: true,
                        textColor: AppColors(context).primaryColor,
                      ),
                    const Spacer(),
                    if (_currentPage < 3)
                      CustomBotton(
                        loading: isLoading,
                        title: _currentPage == 2
                            ? AppText(context, isFunction: true).finish
                            : AppText(context, isFunction: true).next,
                        onTap: () {
                          if (key.currentState!.validate()) {
                            _currentPage == 2
                                ? appProvider.saveTellUsMore(
                                    desc: desc.text,
                                    mobile: phone.text,
                                  )
                                : null;

                            _currentPage == 2 ? addReview() : null;

                            if (_currentPage == 1 &&
                                (appProvider.selectedAnswers.length !=
                                    widget.questionsModel?.questions.length)) {
                              showDialog(
                                context: context,
                                builder: (context) => WidgetDialog(
                                    title: AppText(context, isFunction: true)
                                        .warning,
                                    desc: AppText(context, isFunction: true)
                                        .youhavetoanswerallquestions,
                                    isError: true),
                              );
                            } else {
                              nextPage();
                            }
                          }
                        },
                        height: AppSize(context).height * 0.045,
                        width: AppSize(context).width * 0.2,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future addReview() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() => isLoading = true);
    await ReviewsApi.addReview(
      token: appProvider.userModel?.token ?? "",
      phone: phone.text,
      desc: desc.text,
      customerQuestion: appProvider.selectedAnswers,
    ).then((value) async {
      if (value) {
        appProvider.clearAnswers();
        setState(() => isLoading = false);
      } else {
        setState(() => isLoading = false);
      }
    });
  }

  Widget stepOne(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _animateStepOne ? 1 : 0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: child,
            ),
          ),
          child: Image.asset(
            "assets/image/image.png",
            // width: AppSize(context).width * .5,
            height: AppSize(context).height * .1,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedOpacity(
          opacity: _animateStepOne ? 1 : 0,
          duration: const Duration(milliseconds: 600),
          child: Text(
            AppText(context, isFunction: true).thisApp,
            style: TextStyle(
              fontSize: AppSize(context).mediumText3,
              color: AppColors(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildAnimatedIcon(
              "assets/icon/smile.svg",
              AppColors.greenColor,
              delay: 0,
            ),
            buildAnimatedIcon(
              "assets/icon/good.svg",
              AppColors(context).primaryColor,
              delay: 200,
            ),
            buildAnimatedIcon(
              "assets/icon/sadface.svg",
              AppColors.redColor,
              delay: 400,
            ),
          ],
        ),
        const SizedBox(height: 20),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _animateStepOne ? 1 : 0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: child,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Text(
              AppText(context, isFunction: true).howwasyourexperience,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSize(context).largText3,
                color: AppColors(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAnimatedIcon(String assetPath, Color color, {int delay = 0}) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedSvgPath = assetPath;
          selectedColor = color;
        });
        nextPage();
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: _animateStepOne ? 1 : 0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: 1,
              child: child,
            ),
          );
        },
        child: SvgPicture.asset(
          assetPath,
          color: color,
          width: 80,
          height: 80,
        ),
      ),
    );
  }

  Widget stepTwo(BuildContext context,
      {String? image, Color? iconColor, String? title}) {
    return SingleChildScrollView(
      // ✅ Important: wrap everything to avoid overflow in PageView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                image ?? "assets/icon/smile.svg",
                color: iconColor ?? AppColors.greenColor,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 5),
              Expanded(
                // ✅ Prevent Row overflow
                child: Text(
                  " ${AppText(context, isFunction: true).whatmadeyou} ${image?.contains("smile") ?? false ? "${AppText(context, isFunction: true).happy}" : image?.contains("sadface") ?? false ? "${AppText(context, isFunction: true).bad}" : "${AppText(context, isFunction: true).good}"}?",
                  style: TextStyle(
                    fontSize: AppSize(context).smallText1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.backgroundColor),
          const SizedBox(height: 10),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.questionsModel?.questions.length ?? 0,
            itemBuilder: (context, index) {
              final question = widget.questionsModel!.questions[index];
              final selectedRating =
                  context.watch<AppProvider>().getRating(question.id);

              return ListRateTypeWidget(
                title: question.title,
                selectedRating: selectedRating,
                onRatingSelected: (rating) {
                  context.read<AppProvider>().selectAnswer(question.id, rating);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget stepThree(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset("assets/icon/smile.svg",
                color: AppColors.greenColor, width: 40, height: 40),
            const SizedBox(width: 5),
            Text(
              "${AppText(context, isFunction: true).tellusmore}",
              style: TextStyle(
                fontSize: AppSize(context).smallText1,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        const Divider(color: AppColors.backgroundColor),
        const SizedBox(height: 10),
        WidgetTextField(
          "${"${AppText(context, isFunction: true).tellusmore}"} ...",
          maxLines: 3,
          controller: desc,
          validator: (p0) {
            if (p0!.isEmpty) {
              return AppText(context, isFunction: true).pleaseenteryourfeedback;
            }
            return null;
          },
        ),
        SizedBox(height: AppSize(context).height * 0.02),
        WidgetTextField(
          AppText(context, isFunction: true).phone,
          validator: (p0) {
            if (p0!.isEmpty) {
              return AppText(context, isFunction: true)
                  .pleaseenteryourphonenumber;
            }
            return null;
          },
          controller: phone,
          keyboardType: const TextInputType.numberWithOptions(),
        ),
      ],
    );
  }

  Widget thankYouPage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(opacity: 1, child: child),
              );
            },
            child: SvgPicture.asset(
              "assets/icon/smile.svg",
              width: 80,
              height: 80,
              color: AppColors(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: child,
              ),
            ),
            child: Text(
              AppText(context, isFunction: true).thankyou,
              style: TextStyle(
                fontSize: AppSize(context).largText2,
                fontWeight: FontWeight.bold,
                color: AppColors(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppText(context, isFunction: true).weappreciateyourfeedback,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSize(context).smallText1,
              color: AppColors.greyColor1,
            ),
          ),
          SizedBox(height: AppSize(context).height * .2),
          CustomBotton(
            title: AppText(context, isFunction: true).ok,
            onTap: () {
              pop(context);
            },
          )
        ],
      ),
    );
  }
}
