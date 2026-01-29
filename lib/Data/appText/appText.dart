import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Data/Functions/cash_strings.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';

class AppText {
  BuildContext context;
  bool? isFunction;
  AppText(this.context, {this.isFunction = false});

  String? languages = CacheHelper.getData(key: LANG_CACHE);

  AppProvider get languageProvider => Provider.of<AppProvider>(context, listen: isFunction == false ? true : false);

  String get langCode => languages ?? 'en';

  String getTranslation(String key) {
    
    try {
      final languageList = languageProvider.allLanguage
            .where((element) => element.key == langCode)
          .toList();
      
      if (languageList.isEmpty) return '';
      
      final languages = languageList.first.languages;
      if (languages == null || languages.isEmpty) return '';
      
      try {
        final translation = languages.firstWhere(
          (element) => element.wordKey == key,
        );
        return translation.value ?? '';
      } catch (e) {
        // Translation key not found, return empty string
        return '';
      }
    } catch (e) {
      // Return empty string if any error occurs
      return '';
    }
  }

  String get submitFeedback => getTranslation('submitFeedback');
  String get wefixLocation => getTranslation('wefixLocation');
  String get remarks => getTranslation('remarks');
  String get complaint => getTranslation('complaint');
  String get suggestion => getTranslation('suggestion');
  String get weValueYourTime => getTranslation('weValueYourTime');
  String get youtube => getTranslation('youtube');
  String get chat => getTranslation('chat');
  String get faq => getTranslation('faq');
  String get whatsapp => getTranslation('whatsapp');
  String get callCenter => getTranslation('callCenter');
  String get callUs => getTranslation('callUs');
  String get forEmergencies => getTranslation('forEmergencies');
  String get home => getTranslation('home');
  String get noteM => getTranslation('noteM');
  String get youcansearch => getTranslation('youcansearch');
  String get checkProfile => getTranslation('checkProfile');
  String get yourdetails => getTranslation('yourdetails');
  String get searchforservice => getTranslation('searchforservice');
  String get unlimited => getTranslation('unlimited');
  String get editAppointmentTime => getTranslation('editAppointmentTime');
  String get editAppointmentTimeDescription => getTranslation('editAppointmentTimeDescription');

  String get addAdditionalServices => getTranslation('addAdditionalServices');
  String get addAdditionalServicesDescription => getTranslation('addAdditionalServicesDescription');

  String get viewYourAttachments => getTranslation('viewYourAttachments');
  String get viewYourAttachmentsDescription => getTranslation('viewYourAttachmentsDescription');

  String get continueYourAppointment => getTranslation('continueYourAppointment');
  String get continueYourAppointmentDescription => getTranslation('continueYourAppointmentDescription');
  String get pleaseSelectTime => getTranslation('pleaseSelectTime');

  String get discount => getTranslation('discount');
  String get startfrom => getTranslation('startfrom');
  String get interiorDesign => getTranslation('interiorDesign');
  String get requestRegistered => getTranslation('requestRegistered');
  String get visitScheduled => getTranslation('visitScheduled');
  String get readytoVisit => getTranslation('readytoVisit');
  String get vsitScheduled => getTranslation('vsitScheduled');
  String get visitCompleted => getTranslation('visitCompleted');
  String get awaitingRating => getTranslation('awaitingRating');
  String get preparingMaterials => getTranslation('preparingMaterials');
  String get waitingforConfirmation => getTranslation('waitingforConfirmation');

  String get changeLocation => getTranslation('changeLocation');
  String get changeLocationDescription => getTranslation('changeLocationDescription');

  String get getDiscount => getTranslation('getDiscount');
  String get getDiscountDescription => getTranslation('getDiscountDescription');

  String get paymentSummary => getTranslation('paymentSummary');
  String get paymentSummaryDescription => getTranslation('paymentSummaryDescription');

  String get placeOrderAndChoosePaymentMethod => getTranslation('placeOrderAndChoosePaymentMethod');
  String get placeOrderAndChoosePaymentMethodDescription => getTranslation('placeOrderAndChoosePaymentMethodDescription');

  String get proAtt => getTranslation('proAtt');
  String get corrective => getTranslation('corrective');
  String get femaleService => getTranslation('femaleService');
  String get emeregencyService => getTranslation('emeregencyService');
  String get correctivevisits => getTranslation('correctivevisits');
  String get preventivevisits => getTranslation('preventivevisits');

  String get consultations => getTranslation('consultations');

  String get youwillbechargedTicketextra => getTranslation('youwillbechargedTicketextra');

  String get visa => getTranslation('visa');
  String get cliq => getTranslation('cliq');
  String get confirmAppointment => getTranslation('confirmAppointment');
  String get confirmm => getTranslation('confirmm');

  // String get wallet => getTranslation('wallet');
  String get paypal => getTranslation('paypal');

  String get wearesorryapp => getTranslation('wearesorryapp');
  String get thisservice => getTranslation('thisservice');

  String get ticketM => getTranslation('ticketM');
  String get paylater => getTranslation('paylater');

  String get progressOverview => getTranslation('progressOverview');

  String get services => getTranslation('services');

  String get femaleUse => getTranslation('femaleUse');

  String get ticket => getTranslation('ticket');
  String get rate => getTranslation('rate');
  String get jod => getTranslation('jod');
  String get youwillbecharged10JODextra => getTranslation('youwillbecharged10JODextra');
  String get otpWrong => getTranslation('otpWrong');
  String get subSuccess => getTranslation('subSuccess');
  String get preventivemaintenancevisit => getTranslation('preventivemaintenancevisit');
  String get myProperty => getTranslation('myProperty');
  String get addProperty => getTranslation('addProperty');
  String get propertyName => getTranslation('propertyName');
  String get propertyType => getTranslation('propertyType');
  String get appartmentno => getTranslation('appartmentno');
  String get isWithFemale => getTranslation('isWithFemale');
  String get signUpSuccessfully => getTranslation('signUpSuccessfully');
  String get enterDetails => getTranslation('enterDetails');
  String get apartmentAge => getTranslation('apartmentAge');
  String get distanceFromCenter => getTranslation('distanceFromCenter');
  String get calculatedPrice => getTranslation('calculatedPrice');
  String get pleaseFillAllFields => getTranslation('pleaseFillAllFields');
  String get pleaseCalculateFirst => getTranslation('pleaseCalculateFirst');
  String get calculate => getTranslation('calculate');
  String get proceedToPayment => getTranslation('proceedToPayment');

  String get cart => getTranslation('cart');
  String get category => getTranslation('category');
  String get order => getTranslation('order');
  String get profile => getTranslation('profile');
  String get shops => getTranslation('shops');
  String get aboutUs => getTranslation('aboutUs');
  String get find => getTranslation('find');
  String get active => getTranslation('active');
  String get add => getTranslation('add');
  String get addCarDetails => getTranslation('addCarDetails');
  String get addCarInformation => getTranslation('addCarInformation');
  String get address => getTranslation('address');
  String get back => getTranslation('back');
  String get city => getTranslation('city');
  String get verify => getTranslation('verify');
  String get verifyYourMobailNumber => getTranslation('verifyYourMobailNumber');
  String get wesentcodetothenumber => getTranslation('wesentcodetothenumber');
  String get dontreceivecode => getTranslation('dontreceivecode');
  String get resend => getTranslation('resend');
  String get popularServices => getTranslation('popularServices');
  String get specialOffer => getTranslation('specialOffer');
  // String get searchforservice => getTranslation('searchforservice');
  String get addnewaddress => getTranslation('addnewaddress');
  String get setasdefaultaddress => getTranslation('setasdefaultaddress');
  String get dateTime => getTranslation('dateTime');
  String get change => getTranslation('change');
  String get technicianGender => getTranslation('technicianGender');
  String get female => getTranslation('female');
  String get male => getTranslation('male');
  String get selectDateTime => getTranslation('selectDateTime');
  String get later => getTranslation('later');
  String get emergency => getTranslation('emergency');
  String get emergencyContactus => getTranslation('emergencyContactus');

  String get bad => getTranslation('bad');
  String get good => getTranslation('good');
  String get happy => getTranslation('happy');
  String get tellusmore => getTranslation('tellusmore');
  String get remove => getTranslation('remove');

  String get youhavetoanswerallquestions => getTranslation('youhavetoanswerallquestions');

  String get location => getTranslation('location');
  String get stopRecording => getTranslation('stopRecording');
  String get previewnotavailableforthisfiletype => getTranslation('previewnotavailableforthisfiletype');

  String get uploadFilefromDevice => getTranslation('uploadFilefromDevice');

  String get subject => getTranslation('subject');
  String get month => getTranslation('month');
  String get orprepayannually => getTranslation('orprepayannually');

  String get recommended => getTranslation('recommended');
  String get comparePlans => getTranslation('comparePlans');

  String get type => getTranslation('type');
  String get hours => getTranslation('hours');

  String get maintenanceTicketDetails => getTranslation('maintenanceTicketDetails');
  String get customerDetails => getTranslation('customerDetails');
  String get issueDescription => getTranslation('issueDescription');
  String get serviceProviderActions => getTranslation('serviceProviderActions');
  String get estimatedTime => getTranslation('estimatedTime');
  String get partsrequired => getTranslation('partsrequired');
  String get requiredTools => getTranslation('requiredTools');
  String get completionChecklist => getTranslation('completionChecklist');
  String get recordVoice => getTranslation('recordVoice');
  String get audioRecorded => getTranslation('audioRecorded');
  String get time => getTranslation('time');
  String get describeyourproblem => getTranslation('describeyourproblem');
  String get needafemaletechnicianforsupport => getTranslation('needafemaletechnicianforsupport');
  String get Youhavetochooseproparety => getTranslation('Youhavetochooseproparety');

  String get contractDetails => getTranslation('contractDetails');

  String get nowYouCanSelect => getTranslation('nowYouCanSelect');

  String get addYourService => getTranslation('addYourService');

  String get nowyoucanadd => getTranslation('nowyoucanadd');

  String get youcanuploadfile => getTranslation('youcanuploadfile');
  String get youcantakepicture => getTranslation('youcantakepicture');
  String get youcanrecord => getTranslation('youcanrecord');

  String get youcandescripe => getTranslation('youcandescripe');

  String get afteraddingAll => getTranslation('afteraddingAll');

  String get contractSummary => getTranslation('contractSummary');
  String get endDate => getTranslation('endDate');
  String get startdate => getTranslation('startdate');
  String get nextVisitDue => getTranslation('nextVisitDue');
  String get usageDetails => getTranslation('usageDetails');

  String get usageDetailss => getTranslation('usageDetailss');
  String get recurringVisits => getTranslation('recurringVisits');
  String get ondemandVisits => getTranslation('ondemandVisits');
  String get emergencyVisits => getTranslation('emergencyVisits');
  String get remainingTime => getTranslation('remainingTime');
  String get daysRemaining => getTranslation('daysRemaining');
  String get renew => getTranslation('renew');
  String get upgrade => getTranslation('upgrade');
  String get wallet => getTranslation('wallet');
  String get history => getTranslation('history');
  String get recordVideo => getTranslation('recordVideo');
  String get notifications => getTranslation('notifications');
  String get socialMedia => getTranslation('socialMedia');
  String get weFixStations => getTranslation('weFixStations');
  String get supportType => getTranslation('supportType');
  String get bookings => getTranslation('bookings');
  String get tickets {
    final translation = getTranslation('tickets');
    // Fallback if translation not found in backend
    if (translation.isEmpty) {
      return langCode == 'ar' ? 'تذاكر' : 'Tickets';
    }
    return translation;
  }
  String get callforemergency => getTranslation('callforemergency');
  String get call => getTranslation('call');
  String get welcomePleaseenteryourdetailsbelow => getTranslation('welcomePleaseenteryourdetailsbelow');
  String get thisfeildcanbeempty => getTranslation('thisfeildcanbeempty');
  String get enterText => getTranslation('enterText');
  String get ofyourgoal => getTranslation('ofyourgoal');
  String get savingsThisYear => getTranslation('savingsThisYear');
  String get additionalfeedback => getTranslation('additionalfeedback');
  String get pleaserateyourexperiencebelow => getTranslation('pleaserateyourexperiencebelow');
  String get serviceFeedback => getTranslation('serviceFeedback');
  String get ratethevendor => getTranslation('ratethevendor');
  String get thankyou => getTranslation('thankyou');
  String get weappreciateyourfeedback => getTranslation('weappreciateyourfeedback');
  String get pleaseenteryourphonenumber => getTranslation('pleaseenteryourphonenumber');
  String get pleaseenteryourfeedback => getTranslation('pleaseenteryourfeedback');
  String get finish => getTranslation('finish');
  String get thisApp => getTranslation('thisApp');
  String get whatmadeyou => getTranslation('whatmadeyou');
  String get howwasyourexperience => getTranslation('howwasyourexperience');
  String get pleaselogintocontinue => getTranslation('pleaselogintocontinue');
  String get skip => getTranslation('skip');
  String get subscribeNow => getTranslation('subscribeNow');
  String get upgradeandSaveBig => getTranslation('upgradeandSaveBig');
  String get subscribenowandsave50JODDonmissoutonthisspecialoffer => getTranslation('subscribenowandsave50JODDonmissoutonthisspecialoffer');
  String get yourtransactionhasbeenfailed => getTranslation('yourtransactionhasbeenfailed');
  String get yourtransactionhasbeensuccessfullycompleted => getTranslation('yourtransactionhasbeensuccessfullycompleted');
  String get estimatedTimeToArrivalminutes => getTranslation('estimatedTimeToArrivalminutes');
  String get responseTime => getTranslation('responseTime');
  String get minutes => getTranslation('minutes');
  String get chooseTechniciaGender => getTranslation('chooseTechniciaGender');
  String get sincethematerialcostexceeds100JODanupfrontpaymentof50requiredWetouchwithyoutoconfirmthematerialprice =>
      getTranslation('sincethematerialcostexceeds100JODanupfrontpaymentof50requiredWetouchwithyoutoconfirmthematerialprice');
  String get canyoutelluswhatmaterialisneeded => getTranslation('canyoutelluswhatmaterialisneeded');
  String get pleaseentertheamount => getTranslation('pleaseentertheamount');
  String get needmaterialfromprovider => getTranslation('needmaterialfromprovider');
  String get thepromocodecantbeempty => getTranslation('thepromocodecantbeempty');
  String get youhavetoaccepttermsandconditions => getTranslation('youhavetoaccepttermsandconditions');
  String get appointmentDetails => getTranslation('appointmentDetails');
  String get attachments => getTranslation('attachments');
  String get viewAttachments => getTranslation('viewAttachments');
  // String get confirmAppointment => getTranslation('confirmAppointment');
  String get attachmentPreview => getTranslation('attachmentPreview');
  String get yourrequesthasbeensentPleasecheckyouremail => getTranslation('yourrequesthasbeensentPleasecheckyouremail');
  String get failedtoSendYourrequest => getTranslation('failedtoSendYourrequest');
  String get close => getTranslation('close');
  String get color => getTranslation('color');
  String get confirm => getTranslation('confirm');
  String get contactUs => getTranslation('contactUs');
  String get costPrice => getTranslation('costPrice');
  String get country => getTranslation('country');
  String get createdDate => getTranslation('createdDate');
  String get currency => getTranslation('currency');
  String get customer => getTranslation('customer');
  String get customerEmailOptional => getTranslation('customerEmailOptional');
  String get customerInformation => getTranslation('customerInformation');
  String get customerName => getTranslation('customerName');
  String get customerPhone => getTranslation('customerPhone');
  String get dashboard => getTranslation('dashboard');
  String get details => getTranslation('details');
  String get detailsoptional => getTranslation('detailsoptional');
  String get edit => getTranslation('edit');
  String get email => getTranslation('email');
  String get ex => getTranslation('ex');
  String get expenses => getTranslation('expenses');
  String get friday => getTranslation('friday');
  String get fuelType => getTranslation('fuelType');
  String get fullName => getTranslation('fullName');
  String get generation => getTranslation('generation');
  String get hello => getTranslation('hello');
  String get invoice => getTranslation('invoice');
  String get invoices => getTranslation('invoices');
  String get language => getTranslation('language');
  String get logout => getTranslation('logout');
  String get menu => getTranslation('menu');
  String get model => getTranslation('model');
  String get monday => getTranslation('monday');
  String get myStore => getTranslation('myStore');
  String get next => getTranslation('next');
  String get no => getTranslation('no');
  String get ok => getTranslation('ok');
  String get or => getTranslation('or');
  String get paymentMethods => getTranslation('paymentMethods');
  String get phone => getTranslation('phone');
  String get previous => getTranslation('previous');
  String get privacyPolicy => getTranslation('privacyPolicy');
  String get refNumber => getTranslation('refNumber');
  String get saturday => getTranslation('saturday');
  String get search => getTranslation('search');
  String get select => getTranslation('select');
  String get selectApictureFromGallery => getTranslation('selectApictureFromGallery');
  String get storeAddress => getTranslation('storeAddress');
  String get storeDomain => getTranslation('storeDomain');
  String get storeEmail => getTranslation('storeEmail');
  String get storeInformation => getTranslation('storeInformation');
  String get storeName => getTranslation('storeName');
  String get storeSocialLinks => getTranslation('storeSocialLinks');
  String get storeabout => getTranslation('storeabout');
  String get storemobail => getTranslation('storemobail');
  String get storephone => getTranslation('storephone');
  String get subTotal => getTranslation('subTotal');
  String get submit => getTranslation('submit');
  String get sunday => getTranslation('sunday');
  String get termsAndConditions => getTranslation('termsAndConditions');
  String get thursday => getTranslation('thursday');
  String get title => getTranslation('title');
  String get totalReviews => getTranslation('totalReviews');
  String get totalViews => getTranslation('totalViews');
  String get tuesday => getTranslation('tuesday');
  String get undefined => getTranslation('undefined');
  String get value => getTranslation('value');
  String get viewInvoiceAsPdf => getTranslation('viewInvoiceAsPdf');
  String get wednesday => getTranslation('wednesday');
  String get year => getTranslation('year');
  String get adddd => getTranslation('adddd');
  String get supplireLogin => getTranslation('supplireLogin');
  String get login => getTranslation('login');
  String get automotivePartAccessories => getTranslation('automotivePartAccessories');
  String get joinTheMostComperaccc => getTranslation('joinTheMostComperaccc');
  String get emailAddress => getTranslation('emailAddress');
  String get password => getTranslation('password');
  String get byContinueWithYourEmailAgree => getTranslation('byContinueWithYourEmailAgree');
  String get forgetPassword => getTranslation('forgetPassword');
  String get total => getTranslation('total');
  String get continuesss => getTranslation('continuesss');
  String get price => getTranslation('price');
  String get yes => getTranslation('yes');
  String get update => getTranslation('update');
  String get youCanUploadedUpTo10Pictures => getTranslation('youCanUploadedUpTo10Pictures');
  String get youLikeToTellUsAboutSomtheng => getTranslation('youLikeToTellUsAboutSomtheng');
  String get youeMessage => getTranslation('youeMessage');
  String get warning => getTranslation('warning');
  String get share => getTranslation('share');
  String get sucessSendYourMessage => getTranslation('sucessSendYourMessage');
  String get somethingErrorInSendYourMessage => getTranslation('somethingErrorInSendYourMessage');
  String get sucessUpdateProfile => getTranslation('sucessUpdateProfile');
  String get somethingErrorInUpdateProfile => getTranslation('somethingErrorInUpdateProfile');
  String get enterSellPrice => getTranslation('enterSellPrice');
  String get enterPayment => getTranslation('enterPayment');
  String get attachment => getTranslation('attachment');
  String get addAttachment => getTranslation('addAttachment');
  String get status => getTranslation('status');
  String get filter => getTranslation('filter');
  String get reset => getTranslation('reset');
  String get filterMenu => getTranslation('filterMenu');
  String get totalSales => getTranslation('totalSales');
  String get showMore => getTranslation('showMore');
  String get editCar => getTranslation('editCar');
  String get editWishlist => getTranslation('editWishlist');
  String get required => getTranslation('required');
  String get invalidEmail => getTranslation('invalidEmail');
  String get invoiceInformation => getTranslation('invoiceInformation');
  String get show => getTranslation('show');
  String get solid => getTranslation('solid');
  String get inStock => getTranslation('inStock');
  String get all => getTranslation('all');
  String get sellPrice => getTranslation('sellPrice');
  String get nottt => getTranslation('nottt');
  String get taxNumber => getTranslation('taxNumber');
  String get enterYourStoreDomain => getTranslation('enterYourStoreDomain');
  String get enterYourAddress => getTranslation('enterYourAddress');
  String get facebook => getTranslation('facebook');
  String get enterYourFacebookURL => getTranslation('enterYourFacebookURL');
  String get instgram => getTranslation('instgram');
  String get enterYourInstgramURL => getTranslation('enterYourInstgramURL');
  String get twitter => getTranslation('twitter');
  String get enterYourTwitterURL => getTranslation('enterYourTwitterURL');
  String get linkedIn => getTranslation('linkedIn');
  String get enterYourLinkedInURL => getTranslation('enterYourLinkedInURL');
  String get selectYourCountry => getTranslation('selectYourCountry');
  String get options => getTranslation('options');
  String get enterCustomerName => getTranslation('enterCustomerName');
  String get enterCustomerPhone => getTranslation('enterCustomerPhone');
  String get optional => getTranslation('optional');
  String get selectPaymentMethods => getTranslation('selectPaymentMethods');
  String get enterYourNotes => getTranslation('enterYourNotes');
  String get viewMore => getTranslation('viewMore');
  String get sendToEmail => getTranslation('sendToEmail');
  String get send => getTranslation('send');
  String get delete => getTranslation('delete');
  String get checkYourEmail => getTranslation('checkYourEmail');
  String get checkYourEmail2 => getTranslation('checkYourEmail2');
  String get someThingError => getTranslation('someThingError');
  String get emailorpasswordincorrect => getTranslation('emailorpasswordincorrect');
  String get invalidPhone => getTranslation('invalidPhone');
  String get empty1 => getTranslation('empty1');
  String get empty2 => getTranslation('empty2');
  String get empty11 => getTranslation('empty11');
  String get empty22 => getTranslation('empty22');
  String get jan => getTranslation('jan');
  String get feb => getTranslation('feb');
  String get mar => getTranslation('mar');
  String get apr => getTranslation('apr');
  String get may => getTranslation('may');
  String get jun => getTranslation('jun');
  String get jul => getTranslation('jul');
  String get aug => getTranslation('aug');
  String get sep => getTranslation('sep');
  String get oct => getTranslation('oct');
  String get nov => getTranslation('nov');
  String get dec => getTranslation('dec');
  String get monthlySales => getTranslation('monthlySales');
  String get youdonthavepermion => getTranslation('youdonthavepermion');
  String get products => getTranslation('products');
  String get categories => getTranslation('categories');
  String get viewAll => getTranslation('viewAll');
  String get allShops => getTranslation('allShops');
  String get items => getTranslation('items');
  String get brands => getTranslation('brands');
  String get caht => getTranslation('caht');
  String get allProduct => getTranslation('allProduct');
  String get mycarts => getTranslation('mycarts');
  String get paymentSum => getTranslation('paymentSum');
  String get checkout => getTranslation('checkout');
  String get cartsProducts => getTranslation('cartsProducts');
  String get shippingAddress => getTranslation('shippingAddress');
  String get selectoneaddressforshipping => getTranslation('selectoneaddressforshipping');
  String get firstName => getTranslation('firstName');
  String get lastName => getTranslation('lastName');
  String get addressType => getTranslation('addressType');
  String get buildingNumber => getTranslation('buildingNumber');
  String get addAddress => getTranslation('addAddress');
  String get youneedtoplacethemarkeronthemap => getTranslation('youneedtoplacethemarkeronthemap');
  String get saveonyourorder => getTranslation('saveonyourorder');
  String get shipping => getTranslation('shipping');
  String get applyPromoCode => getTranslation('applyPromoCode');
  String get paywith => getTranslation('paywith');
  String get placeOrder => getTranslation('placeOrder');
  String get youneedtoselectoneshippingcompany => getTranslation('youneedtoselectoneshippingcompany');
  String get orders => getTranslation('orders');
  String get wishlist => getTranslation('wishlist');
  String get addresses => getTranslation('addresses');
  String get massages => getTranslation('massages');
  String get editProfile => getTranslation('editProfile');
  String get editmobile => getTranslation('editmobile');
  String get changepassword => getTranslation('changepassword');
  String get deletemyAccount => getTranslation('deletemyAccount');
  String get noProductFound => getTranslation('noProductFound');
  String get lookslikethereisnoresultforyourseraching => getTranslation('lookslikethereisnoresultforyourseraching');
  String get lookslikewishlistisempty => getTranslation('lookslikewishlistisempty');
  String get yourwishlistisempty => getTranslation('yourwishlistisempty');

  String get shopDeatils => getTranslation('shopDeatils');
  String get desc => getTranslation('desc');
  String get comments => getTranslation('comments');
  String get youcantacinformationwillnotbesharedwiththemerchant => getTranslation('youcantacinformationwillnotbesharedwiththemerchant');
  String get noreviewsyet => getTranslation('noreviewsyet');
  String get setasdefaultlocation => getTranslation('setasdefaultlocation');
  String get popularSearch => getTranslation('popularSearch');
  String get loginnow => getTranslation('loginnow');
  String get youneedtologintousethisfeature => getTranslation('youneedtologintousethisfeature');
  String get similarproduct => getTranslation('similarproduct');
  String get featueredProduct => getTranslation('featueredProduct');
  String get askQuestion => getTranslation('askQuestion');
  String get addToCart => getTranslation('addToCart');
  String get continueshopping => getTranslation('continueshopping');
  String get viewcart => getTranslation('viewcart');
  String get feature => getTranslation('feature');
  String get subscription => getTranslation('subscription');
  String get credit => getTranslation('credit');
  String get debit => getTranslation('debit');

  String get transactiontype => getTranslation('transactiontype');

  String get pleaseenteravalidnumber => getTranslation('pleaseenteravalidnumber');

  String get entertheamountyouwanttoaddtoyourwallet => getTranslation('entertheamountyouwanttoaddtoyourwallet');

  String get dontmissoutSubscribenowforspecialServices => getTranslation('dontmissoutSubscribenowforspecialServices');

  String get addedToCart => getTranslation('addedToCart');
  String get withdraw => getTranslation('withdraw');
  String get deposit => getTranslation('deposit');

  String get jODMonth => getTranslation('jODMonth');
  String get availableBalance => getTranslation('availableBalance');

  String get cancelBooking => getTranslation('cancelBooking');

  String get compare => getTranslation('compare');
  String get added => getTranslation('added');
  String get maketransaction => getTranslation('maketransaction');
  String get recenttransactions => getTranslation('recenttransactions');

  String get loginAsG => getTranslation('loginAsG');
  String get dontHavAccount => getTranslation('dontHavAccount');
  String get createOne => getTranslation('createOne');
  String get theUsername => getTranslation('theUsername');
  String get terms => getTranslation('terms');
  String get already => getTranslation('already');
  String get signIn => getTranslation('signIn');
  String get iAgreetothe => getTranslation('iAgreetothe');

  String get and => getTranslation('and');
  String get passworddoesnotmatch => getTranslation('passworddoesnotmatch');

  String get confirmPassword => getTranslation('confirmPassword');

  String get createAccount => getTranslation('createAccount');

  String get thephoneyouentereisalreadyinusePleasetradifferentphone => getTranslation('thephoneyouentereisalreadyinusePleasetradifferentphone');

  String get mustbecontainatleast8characters => getTranslation('mustbecontainatleast8characters');

  String get successfully => getTranslation('successfully');
  String get yourCommentWasSendSuccessfully => getTranslation('yourcommentwassendsuccessfully');
  String get failedToSendYourComments => getTranslation('failedtoSendYourComments');
  String get topSoldProducts => getTranslation('topSoldProducts');
  String get orderStatus => getTranslation('orderStatus');
  String get paymentStatus => getTranslation('paymentStatus');
  String get note => getTranslation('note');

  String get orderCanceledSuccessfully => getTranslation('ordercanceledSuccessfully');
  String get failedToCancelOrder => getTranslation('failedtoCancelOrder');
  String get personalInformation => getTranslation('personalInformtion');
  String get yourInformationHasBeenUpdatedSuccessfully => getTranslation('yourinformationhasbeenupdatedsuccessfully');
  String get thisFieldCantBeEmpty => getTranslation('thisfeildcanbeempty');
  String get selectAPictureFromGallery => getTranslation('selectaPictureFromGallery');
  String get takeAPictureFromCamera => getTranslation('takeaPictureFromCamera');
  String get currentPassword => getTranslation('currentPassword');
  String get newPassword => getTranslation('newPassword');
  String get passwordMustHaveSymbolsNumbersAndLetters => getTranslation('passwordmusthavesymbolsnumbersandletters');

  String get thePasswordIsDifferentFromThePreviousOne => getTranslation('thePasswordIsDifferentFromThePreviousOne');
  String get yourPasswordHasBeenUpdatedSuccessfully => getTranslation('yourpasswordhasbeenupdatedsuccessfully.');
  String get editAddress => getTranslation('editAddress');

  String get youNeedToPlaceTheMarkerOnTheMap => getTranslation('youneedtoplacethemarkeronthemap');
  String get writeYourMessage => getTranslation('writeYourMessage');
  String get sendMessage => getTranslation('sendMessage');
  String get askQuestions => getTranslation('askQuestions');
  String get yourContactInformationWillNotBeSharedWithTheMerchant => getTranslation('yourcontacinformationillnotbeharedwiththemerchant');
  String get from => getTranslation('from');
  String get to => getTranslation('to');

  String get noProductsFounds => getTranslation('noproductsfounds');
  String get setAsDefaultLocation => getTranslation('setasdefaultlocation');
  String get readMore => getTranslation('readmore');
  String get shippingCost => getTranslation('shippingcost');
  String get totalAfterDiscount => getTranslation('totalafterdiscount');
  String get orderSentSuccessfully => getTranslation('orderSentSuuc');
  String get weArePless => getTranslation('weArePless');
  String get serviceUnavailable => getTranslation('serviceUnavailable');
  String get accountDoesNotExist => getTranslation('accountDoesNotExist');
  String get accountInactive => getTranslation('accountInactive');
  String get pleaseLoginWithMobileNumber => getTranslation('pleaseLoginWithMobileNumber');
}
