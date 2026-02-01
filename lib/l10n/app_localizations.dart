import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profile;

  /// No description provided for @shops.
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get shops;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @find.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get find;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addCarDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get addCarDetails;

  /// No description provided for @addCarInformayion.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get addCarInformayion;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmss.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmss;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost price'**
  String get costPrice;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @createdDate.
  ///
  /// In en, this message translates to:
  /// **'Created date'**
  String get createdDate;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @customerEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Customer email '**
  String get customerEmailOptional;

  /// No description provided for @customerInformation.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInformation;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get customerName;

  /// No description provided for @customerPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer phone'**
  String get customerPhone;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @detailsoptional.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsoptional;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @ex.
  ///
  /// In en, this message translates to:
  /// **'EX'**
  String get ex;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @fuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel type'**
  String get fuelType;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @generation.
  ///
  /// In en, this message translates to:
  /// **'Trim'**
  String get generation;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @myStore.
  ///
  /// In en, this message translates to:
  /// **'My Store'**
  String get myStore;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @refNumber.
  ///
  /// In en, this message translates to:
  /// **'Ref. Number'**
  String get refNumber;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search....'**
  String get search;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectApictureFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select image from your device'**
  String get selectApictureFromGallery;

  /// No description provided for @storeAddress.
  ///
  /// In en, this message translates to:
  /// **'Store Address'**
  String get storeAddress;

  /// No description provided for @storeDomain.
  ///
  /// In en, this message translates to:
  /// **'Store domain'**
  String get storeDomain;

  /// No description provided for @storeEmail.
  ///
  /// In en, this message translates to:
  /// **'Store email'**
  String get storeEmail;

  /// No description provided for @storeInformation.
  ///
  /// In en, this message translates to:
  /// **'Store information'**
  String get storeInformation;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeName;

  /// No description provided for @storeSocialLinks.
  ///
  /// In en, this message translates to:
  /// **'Store Social Links'**
  String get storeSocialLinks;

  /// No description provided for @storeabout.
  ///
  /// In en, this message translates to:
  /// **'Store about'**
  String get storeabout;

  /// No description provided for @storemobail.
  ///
  /// In en, this message translates to:
  /// **'Store mobile'**
  String get storemobail;

  /// No description provided for @storephone.
  ///
  /// In en, this message translates to:
  /// **'Store phone'**
  String get storephone;

  /// No description provided for @subTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get subTotal;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @totalReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get totalReviews;

  /// No description provided for @totalViews.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get totalViews;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @undefined.
  ///
  /// In en, this message translates to:
  /// **'Take a picture from camera'**
  String get undefined;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @viewInvoiceAsPdf.
  ///
  /// In en, this message translates to:
  /// **'View Invoice as PDF'**
  String get viewInvoiceAsPdf;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @adddd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get adddd;

  /// No description provided for @supplireLogin.
  ///
  /// In en, this message translates to:
  /// **'Supplier Login'**
  String get supplireLogin;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @automotivePartAccessories.
  ///
  /// In en, this message translates to:
  /// **'Automotive part & accessories'**
  String get automotivePartAccessories;

  /// No description provided for @joinTheMostComperaccc.
  ///
  /// In en, this message translates to:
  /// **'Join the most comprehensive marketplace for automotive part & accessories'**
  String get joinTheMostComperaccc;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @byContinueWithYourEmailAgree.
  ///
  /// In en, this message translates to:
  /// **'By Continue with your email, agree with our terms and conditions'**
  String get byContinueWithYourEmailAgree;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget Your Password?'**
  String get forgetPassword;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @continuesss.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuesss;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @youCanUploadedUpTo10Pictures.
  ///
  /// In en, this message translates to:
  /// **'You can upload up to 10 pictures'**
  String get youCanUploadedUpTo10Pictures;

  /// No description provided for @youLikeToTellUsAboutSomtheng.
  ///
  /// In en, this message translates to:
  /// **'You\'d like to tell us about something? We look forward to hearing from you.'**
  String get youLikeToTellUsAboutSomtheng;

  /// No description provided for @youeMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Message .....'**
  String get youeMessage;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'share'**
  String get share;

  /// No description provided for @sucessSendYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Success Send Your Message'**
  String get sucessSendYourMessage;

  /// No description provided for @somethingErrorInSendYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Something Error in Send Your Message'**
  String get somethingErrorInSendYourMessage;

  /// No description provided for @sucessUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Success Update Profile'**
  String get sucessUpdateProfile;

  /// No description provided for @somethingErrorInUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Something Error in Update Profile'**
  String get somethingErrorInUpdateProfile;

  /// No description provided for @enterSellPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter Sell Price'**
  String get enterSellPrice;

  /// No description provided for @enterPayment.
  ///
  /// In en, this message translates to:
  /// **'Enter Payments Method'**
  String get enterPayment;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @addAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add Attachment'**
  String get addAttachment;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @filterMenu.
  ///
  /// In en, this message translates to:
  /// **'Filter Menu'**
  String get filterMenu;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @editCar.
  ///
  /// In en, this message translates to:
  /// **'Edit Car'**
  String get editCar;

  /// No description provided for @editWishlist.
  ///
  /// In en, this message translates to:
  /// **'Edit Interest'**
  String get editWishlist;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'invalid email'**
  String get invalidEmail;

  /// No description provided for @invoiceInformation.
  ///
  /// In en, this message translates to:
  /// **'Invoice Information'**
  String get invoiceInformation;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @solid.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get solid;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @sellPrice.
  ///
  /// In en, this message translates to:
  /// **'Sell Price'**
  String get sellPrice;

  /// No description provided for @nottt.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get nottt;

  /// No description provided for @taxNumber.
  ///
  /// In en, this message translates to:
  /// **'Tax Number'**
  String get taxNumber;

  /// No description provided for @enterYourStoreDomain.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Store Domain'**
  String get enterYourStoreDomain;

  /// No description provided for @enterYourAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Address'**
  String get enterYourAddress;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @enterYourFacebookURL.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Facebook URL'**
  String get enterYourFacebookURL;

  /// No description provided for @instgram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instgram;

  /// No description provided for @enterYourInstgramURL.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Instagram URL'**
  String get enterYourInstgramURL;

  /// No description provided for @twitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter'**
  String get twitter;

  /// No description provided for @enterYourTwitterURL.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Twitter URL'**
  String get enterYourTwitterURL;

  /// No description provided for @linkedIn.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get linkedIn;

  /// No description provided for @enterYourLinkedInURL.
  ///
  /// In en, this message translates to:
  /// **'Enter Your LinkedIn URL'**
  String get enterYourLinkedInURL;

  /// No description provided for @selectYourCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Your Country'**
  String get selectYourCountry;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @enterCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Enter Customer Name'**
  String get enterCustomerName;

  /// No description provided for @enterCustomerPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter Customer Phone'**
  String get enterCustomerPhone;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @selectPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Methods'**
  String get selectPaymentMethods;

  /// No description provided for @enterYourNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Notes .....'**
  String get enterYourNotes;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// No description provided for @sendToEmail.
  ///
  /// In en, this message translates to:
  /// **'Send to Email'**
  String get sendToEmail;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmail;

  /// No description provided for @checkYourEmail2.
  ///
  /// In en, this message translates to:
  /// **' Success Send \n Check Your Email'**
  String get checkYourEmail2;

  /// No description provided for @someThingError.
  ///
  /// In en, this message translates to:
  /// **'Something Error'**
  String get someThingError;

  /// No description provided for @emailorpasswordincorrect.
  ///
  /// In en, this message translates to:
  /// **'Email or password incorrect'**
  String get emailorpasswordincorrect;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhone;

  /// No description provided for @empty1.
  ///
  /// In en, this message translates to:
  /// **'Empty Interest'**
  String get empty1;

  /// No description provided for @empty2.
  ///
  /// In en, this message translates to:
  /// **'Empty Invoices'**
  String get empty2;

  /// No description provided for @empty11.
  ///
  /// In en, this message translates to:
  /// **'You dont have any interest \n Add Interest'**
  String get empty11;

  /// No description provided for @empty22.
  ///
  /// In en, this message translates to:
  /// **'You dont have any Invoice'**
  String get empty22;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @monthlySales.
  ///
  /// In en, this message translates to:
  /// **'Monthly Sales'**
  String get monthlySales;

  /// No description provided for @youdonthavepermion.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission'**
  String get youdonthavepermion;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categorise'**
  String get categories;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @allShops.
  ///
  /// In en, this message translates to:
  /// **'All Shops'**
  String get allShops;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @brands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get brands;

  /// No description provided for @caht.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get caht;

  /// No description provided for @allProduct.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProduct;

  /// No description provided for @mycarts.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get mycarts;

  /// No description provided for @paymentSum.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSum;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @cartsProducts.
  ///
  /// In en, this message translates to:
  /// **'Cart Products'**
  String get cartsProducts;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @selectoneaddressforshipping.
  ///
  /// In en, this message translates to:
  /// **'select one address for shipping'**
  String get selectoneaddressforshipping;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @addressType.
  ///
  /// In en, this message translates to:
  /// **'Address Type'**
  String get addressType;

  /// No description provided for @buildingNumber.
  ///
  /// In en, this message translates to:
  /// **'Building Number'**
  String get buildingNumber;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @youneedtoplacethemarkeronthemap.
  ///
  /// In en, this message translates to:
  /// **'You need to place the marker on the map'**
  String get youneedtoplacethemarkeronthemap;

  /// No description provided for @saveonyourorder.
  ///
  /// In en, this message translates to:
  /// **'Save on your order'**
  String get saveonyourorder;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @applyPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Apply promo code'**
  String get applyPromoCode;

  /// No description provided for @paywith.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get paywith;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'place Order'**
  String get placeOrder;

  /// No description provided for @youneedtoselectoneshippingcompany.
  ///
  /// In en, this message translates to:
  /// **'You need to select shipping company'**
  String get youneedtoselectoneshippingcompany;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @massages.
  ///
  /// In en, this message translates to:
  /// **'Massages'**
  String get massages;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @editmobile.
  ///
  /// In en, this message translates to:
  /// **'Edit Mobile'**
  String get editmobile;

  /// No description provided for @changepassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changepassword;

  /// No description provided for @deletemyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deletemyAccount;

  /// No description provided for @noProductFound.
  ///
  /// In en, this message translates to:
  /// **'No Product found'**
  String get noProductFound;

  /// No description provided for @lookslikethereisnoresultforyourseraching.
  ///
  /// In en, this message translates to:
  /// **'Looks like you haven\'t added \n anything to your cart yet'**
  String get lookslikethereisnoresultforyourseraching;

  /// No description provided for @lookslikewishlistisempty.
  ///
  /// In en, this message translates to:
  /// **'Looks like you haven\'t added \n anything to your wishlist yet'**
  String get lookslikewishlistisempty;

  /// No description provided for @yourwishlistisempty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get yourwishlistisempty;

  /// No description provided for @enterText.
  ///
  /// In en, this message translates to:
  /// **'Enter Text'**
  String get enterText;

  /// No description provided for @shopDeatils.
  ///
  /// In en, this message translates to:
  /// **'Shop Details'**
  String get shopDeatils;

  /// No description provided for @desc.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get desc;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @youcantacinformationwillnotbesharedwiththemerchant.
  ///
  /// In en, this message translates to:
  /// **'Your contact information will not be shared with the merchant'**
  String get youcantacinformationwillnotbesharedwiththemerchant;

  /// No description provided for @noreviewsyet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noreviewsyet;

  /// No description provided for @setasdefaultlocation.
  ///
  /// In en, this message translates to:
  /// **'Set as default location'**
  String get setasdefaultlocation;

  /// No description provided for @popularSearch.
  ///
  /// In en, this message translates to:
  /// **'Popular Search'**
  String get popularSearch;

  /// No description provided for @loginnow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginnow;

  /// No description provided for @youneedtologintousethisfeature.
  ///
  /// In en, this message translates to:
  /// **'You need to login to use this feature'**
  String get youneedtologintousethisfeature;

  /// No description provided for @similarproduct.
  ///
  /// In en, this message translates to:
  /// **'Similar Product'**
  String get similarproduct;

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask Question'**
  String get askQuestion;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add To Cart'**
  String get addToCart;

  /// No description provided for @continueshopping.
  ///
  /// In en, this message translates to:
  /// **'Continue shopping'**
  String get continueshopping;

  /// No description provided for @viewcart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewcart;

  /// No description provided for @featueredProduct.
  ///
  /// In en, this message translates to:
  /// **'Featuered Product'**
  String get featueredProduct;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @loginAsG.
  ///
  /// In en, this message translates to:
  /// **'login as a guest'**
  String get loginAsG;

  /// No description provided for @dontHavAccount.
  ///
  /// In en, this message translates to:
  /// **'Dont have an account'**
  String get dontHavAccount;

  /// No description provided for @createOne.
  ///
  /// In en, this message translates to:
  /// **' Create One'**
  String get createOne;

  /// No description provided for @theUsername.
  ///
  /// In en, this message translates to:
  /// **'The username or password you entered is incorrect. Please try again.'**
  String get theUsername;

  /// No description provided for @accountDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'Account does not exist with this phone number'**
  String get accountDoesNotExist;

  /// No description provided for @accountInactive.
  ///
  /// In en, this message translates to:
  /// **'Your account is inactive. Please contact your administrator to activate your account.'**
  String get accountInactive;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'You have to accept on terms and condithions and privacy policy'**
  String get terms;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passworddoesnotmatch.
  ///
  /// In en, this message translates to:
  /// **'Password does not match'**
  String get passworddoesnotmatch;

  /// No description provided for @mustbecontainatleast8characters.
  ///
  /// In en, this message translates to:
  /// **'Must be contain at least 8 characters'**
  String get mustbecontainatleast8characters;

  /// No description provided for @iAgreetothe.
  ///
  /// In en, this message translates to:
  /// **'I Agree to the'**
  String get iAgreetothe;

  /// No description provided for @termsofService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service '**
  String get termsofService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @thephoneyouentereisalreadyinusePleasetradifferentphone.
  ///
  /// In en, this message translates to:
  /// **'The phone you entered is already in use. Please try a different phone'**
  String get thephoneyouentereisalreadyinusePleasetradifferentphone;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @already.
  ///
  /// In en, this message translates to:
  /// **'Alreday have account ? '**
  String get already;

  /// No description provided for @successfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully'**
  String get successfully;

  /// No description provided for @yourcommentwassendsuccessfully.
  ///
  /// In en, this message translates to:
  /// **' Your comment was send successfully'**
  String get yourcommentwassendsuccessfully;

  /// No description provided for @failedtoSendYourComments.
  ///
  /// In en, this message translates to:
  /// **'Failed to Send Your Comments'**
  String get failedtoSendYourComments;

  /// No description provided for @topSoldProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Sold Products'**
  String get topSoldProducts;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @ordercanceledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order canceled Successfully'**
  String get ordercanceledSuccessfully;

  /// No description provided for @failedtoCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to Cancel Order'**
  String get failedtoCancelOrder;

  /// No description provided for @personalInformtion.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformtion;

  /// No description provided for @yourinformationhasbeenupdatedsuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your information has been updated successfully'**
  String get yourinformationhasbeenupdatedsuccessfully;

  /// No description provided for @thisfeildcanbeempty.
  ///
  /// In en, this message translates to:
  /// **'This feild can\'t be empty'**
  String get thisfeildcanbeempty;

  /// No description provided for @selectaPictureFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select a Picture From Gallery'**
  String get selectaPictureFromGallery;

  /// No description provided for @takeaPictureFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a Picture From Camera'**
  String get takeaPictureFromCamera;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile. Please try again.'**
  String get failedToUpdateProfile;

  /// No description provided for @errorOccurredWhileUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while updating your profile.'**
  String get errorOccurredWhileUpdatingProfile;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordmusthavesymbolsnumbersandletters.
  ///
  /// In en, this message translates to:
  /// **'Password must have symbols, numbers, and letters'**
  String get passwordmusthavesymbolsnumbersandletters;

  /// No description provided for @thePasswordIsDifferentFromThePreviousOne.
  ///
  /// In en, this message translates to:
  /// **'The Password Is Different From The Previous One'**
  String get thePasswordIsDifferentFromThePreviousOne;

  /// No description provided for @yourpasswordhasbeenupdatedsuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated successfully.'**
  String get yourpasswordhasbeenupdatedsuccessfully;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @writeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Write Your Message'**
  String get writeYourMessage;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @askQuestions.
  ///
  /// In en, this message translates to:
  /// **'Ask Questions'**
  String get askQuestions;

  /// No description provided for @yourcontacinformationillnotbeharedwiththemerchant.
  ///
  /// In en, this message translates to:
  /// **'Your contact information will not be shared with the merchant'**
  String get yourcontacinformationillnotbeharedwiththemerchant;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get from;

  /// No description provided for @noproductsfounds.
  ///
  /// In en, this message translates to:
  /// **'No products founds'**
  String get noproductsfounds;

  /// No description provided for @readmore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readmore;

  /// No description provided for @shippingcost.
  ///
  /// In en, this message translates to:
  /// **'Shipping cost'**
  String get shippingcost;

  /// No description provided for @totalafterdiscount.
  ///
  /// In en, this message translates to:
  /// **'Total after discount'**
  String get totalafterdiscount;

  /// No description provided for @orderSentSuuc.
  ///
  /// In en, this message translates to:
  /// **'Order Sent Successfully'**
  String get orderSentSuuc;

  /// No description provided for @weArePless.
  ///
  /// In en, this message translates to:
  /// **'We are pleased to inform you that your order has been successfully processed and sent.'**
  String get weArePless;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'verify'**
  String get verify;

  /// No description provided for @verifyYourMobailNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Mobile Number'**
  String get verifyYourMobailNumber;

  /// No description provided for @addTicket.
  ///
  /// In en, this message translates to:
  /// **'Add Ticket'**
  String get addTicket;

  /// No description provided for @lastTickets.
  ///
  /// In en, this message translates to:
  /// **'Last Tickets'**
  String get lastTickets;

  /// No description provided for @correctiveTickets.
  ///
  /// In en, this message translates to:
  /// **'Corrective Tickets'**
  String get correctiveTickets;

  /// No description provided for @emergencyTickets.
  ///
  /// In en, this message translates to:
  /// **'Emergency Tickets'**
  String get emergencyTickets;

  /// No description provided for @shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get shortcuts;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @addBranch.
  ///
  /// In en, this message translates to:
  /// **'Add Branch'**
  String get addBranch;

  /// No description provided for @branches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get branches;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get addEmployee;

  /// No description provided for @preventivevisits.
  ///
  /// In en, this message translates to:
  /// **'Preventive Visits'**
  String get preventivevisits;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid login credentials'**
  String get invalidCredentials;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Service is currently unavailable'**
  String get networkError;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service Unavailable'**
  String get serviceUnavailable;

  /// No description provided for @otpRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get otpRequired;

  /// No description provided for @regularUser.
  ///
  /// In en, this message translates to:
  /// **'My Services'**
  String get regularUser;

  /// No description provided for @companyPersonnel.
  ///
  /// In en, this message translates to:
  /// **'Business Services'**
  String get companyPersonnel;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @createTicket.
  ///
  /// In en, this message translates to:
  /// **'Create Ticket'**
  String get createTicket;

  /// No description provided for @editTicket.
  ///
  /// In en, this message translates to:
  /// **'Edit Ticket'**
  String get editTicket;

  /// No description provided for @updateTicket.
  ///
  /// In en, this message translates to:
  /// **'Update Ticket'**
  String get updateTicket;

  /// No description provided for @ticketTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket Title'**
  String get ticketTitle;

  /// No description provided for @locationMap.
  ///
  /// In en, this message translates to:
  /// **'Location Map'**
  String get locationMap;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @problemDescription.
  ///
  /// In en, this message translates to:
  /// **'Problem Description'**
  String get problemDescription;

  /// No description provided for @serviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Service Description'**
  String get serviceDescription;

  /// No description provided for @ticketType.
  ///
  /// In en, this message translates to:
  /// **'Ticket Type'**
  String get ticketType;

  /// No description provided for @mainService.
  ///
  /// In en, this message translates to:
  /// **'Main Service'**
  String get mainService;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @timeFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get timeFrom;

  /// No description provided for @timeTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get timeTo;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time: From - To'**
  String get timeLabel;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @contractId.
  ///
  /// In en, this message translates to:
  /// **'Contract ID'**
  String get contractId;

  /// No description provided for @branchId.
  ///
  /// In en, this message translates to:
  /// **'Branch ID'**
  String get branchId;

  /// No description provided for @zoneId.
  ///
  /// In en, this message translates to:
  /// **'Zone ID'**
  String get zoneId;

  /// No description provided for @teamLeaderId.
  ///
  /// In en, this message translates to:
  /// **'Team Leader ID'**
  String get teamLeaderId;

  /// No description provided for @technicianId.
  ///
  /// In en, this message translates to:
  /// **'Technician ID'**
  String get technicianId;

  /// No description provided for @havingFemaleEngineer.
  ///
  /// In en, this message translates to:
  /// **'Having Female Engineer'**
  String get havingFemaleEngineer;

  /// No description provided for @withMaterial.
  ///
  /// In en, this message translates to:
  /// **'With Material'**
  String get withMaterial;

  /// No description provided for @ticketCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ticket created successfully'**
  String get ticketCreatedSuccessfully;

  /// No description provided for @ticketUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ticket updated successfully'**
  String get ticketUpdatedSuccessfully;

  /// No description provided for @ticketCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create ticket'**
  String get ticketCreateFailed;

  /// No description provided for @ticketUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update ticket'**
  String get ticketUpdateFailed;

  /// No description provided for @ticketSummary.
  ///
  /// In en, this message translates to:
  /// **'Ticket Summary'**
  String get ticketSummary;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get serviceDetails;

  /// No description provided for @subService.
  ///
  /// In en, this message translates to:
  /// **'Sub Service'**
  String get subService;

  /// No description provided for @ticketStatus.
  ///
  /// In en, this message translates to:
  /// **'Ticket Status'**
  String get ticketStatus;

  /// No description provided for @responseTime.
  ///
  /// In en, this message translates to:
  /// **'Response Time'**
  String get responseTime;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @branchDetails.
  ///
  /// In en, this message translates to:
  /// **'Branch Details'**
  String get branchDetails;

  /// No description provided for @noBranchesFound.
  ///
  /// In en, this message translates to:
  /// **'No branches found'**
  String get noBranchesFound;

  /// No description provided for @branchInformation.
  ///
  /// In en, this message translates to:
  /// **'Branch Information'**
  String get branchInformation;

  /// No description provided for @branchNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Branch Name (English)'**
  String get branchNameEnglish;

  /// No description provided for @branchNameArabic.
  ///
  /// In en, this message translates to:
  /// **'Branch Name (Arabic)'**
  String get branchNameArabic;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @loadingAddress.
  ///
  /// In en, this message translates to:
  /// **'Loading address...'**
  String get loadingAddress;

  /// No description provided for @locationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Location on Map'**
  String get locationOnMap;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @teamLeader.
  ///
  /// In en, this message translates to:
  /// **'Team Leader'**
  String get teamLeader;

  /// No description provided for @teamLeaderName.
  ///
  /// In en, this message translates to:
  /// **'Team Leader Name'**
  String get teamLeaderName;

  /// No description provided for @teamLeaderNameArabic.
  ///
  /// In en, this message translates to:
  /// **'Team Leader Name (Arabic)'**
  String get teamLeaderNameArabic;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @companyInformation.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get companyInformation;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @companyNameArabic.
  ///
  /// In en, this message translates to:
  /// **'Company Name (Arabic)'**
  String get companyNameArabic;

  /// No description provided for @companyTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get companyTitle;

  /// No description provided for @headOfficeAddress.
  ///
  /// In en, this message translates to:
  /// **'Head Office Address'**
  String get headOfficeAddress;

  /// No description provided for @internalId.
  ///
  /// In en, this message translates to:
  /// **'Internal ID'**
  String get internalId;

  /// No description provided for @companyId.
  ///
  /// In en, this message translates to:
  /// **'Company ID'**
  String get companyId;

  /// No description provided for @representativeInformation.
  ///
  /// In en, this message translates to:
  /// **'Representative Information'**
  String get representativeInformation;

  /// No description provided for @representativeName.
  ///
  /// In en, this message translates to:
  /// **'Representative Name'**
  String get representativeName;

  /// No description provided for @representativeMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Representative Mobile Number'**
  String get representativeMobileNumber;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @branchName.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get branchName;

  /// No description provided for @branchNameAr.
  ///
  /// In en, this message translates to:
  /// **'Branch Name (Arabic)'**
  String get branchNameAr;

  /// No description provided for @branchAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Branch added successfully'**
  String get branchAddedSuccessfully;

  /// No description provided for @failedToAddBranch.
  ///
  /// In en, this message translates to:
  /// **'Failed to add branch. Please try again'**
  String get failedToAddBranch;

  /// No description provided for @locationCoordinatesNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Location coordinates not available. Showing default location.'**
  String get locationCoordinatesNotAvailable;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @technicianNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Technicians are not allowed to login to this system.'**
  String get technicianNotAllowed;

  /// No description provided for @subTechnicianNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Sub-Technicians are not allowed to login to this system.'**
  String get subTechnicianNotAllowed;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @tickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// No description provided for @emergencyResponseTime.
  ///
  /// In en, this message translates to:
  /// **'90 - 120 minutes'**
  String get emergencyResponseTime;

  /// No description provided for @ticketTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Ticket Title Required'**
  String get ticketTitleRequired;

  /// No description provided for @ticketTitleMustNotExceed.
  ///
  /// In en, this message translates to:
  /// **'Ticket Title must not exceed 100 characters'**
  String get ticketTitleMustNotExceed;

  /// No description provided for @timeMustBeFromCurrentTo120Minutes.
  ///
  /// In en, this message translates to:
  /// **'Time must be from current time to 120 minutes later'**
  String get timeMustBeFromCurrentTo120Minutes;

  /// No description provided for @emergencyTimeMustBe90To120Minutes.
  ///
  /// In en, this message translates to:
  /// **'Emergency ticket time duration must be between 90 and 120 minutes'**
  String get emergencyTimeMustBe90To120Minutes;

  /// No description provided for @pleaseSelectDateFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a date first'**
  String get pleaseSelectDateFirst;

  /// No description provided for @noAvailableTimeSlots.
  ///
  /// In en, this message translates to:
  /// **'No available time slots for selected date. Please select a different date.'**
  String get noAvailableTimeSlots;

  /// No description provided for @phoneNumberMustBeBetween9And15Digits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be between 9 and 15 digits'**
  String get phoneNumberMustBeBetween9And15Digits;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequired;

  /// No description provided for @updateRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Please update to continue using the app.'**
  String get updateRequiredDescription;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @couldNotOpenStore.
  ///
  /// In en, this message translates to:
  /// **'Could not open store. Please update manually.'**
  String get couldNotOpenStore;

  /// No description provided for @delegated.
  ///
  /// In en, this message translates to:
  /// **'Delegated'**
  String get delegated;

  /// No description provided for @delegatedBy.
  ///
  /// In en, this message translates to:
  /// **'Delegated by'**
  String get delegatedBy;

  /// No description provided for @delegatedToWefix.
  ///
  /// In en, this message translates to:
  /// **'Delegated to Wefix'**
  String get delegatedToWefix;

  /// No description provided for @delegatedToWefixBy.
  ///
  /// In en, this message translates to:
  /// **'Delegated to Wefix by'**
  String get delegatedToWefixBy;

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not Assigned'**
  String get notAssigned;

  /// No description provided for @pleaseLoginWithMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please login using your mobile number'**
  String get pleaseLoginWithMobileNumber;

  /// No description provided for @materialsManagement.
  ///
  /// In en, this message translates to:
  /// **'Materials Management'**
  String get materialsManagement;

  /// No description provided for @addMaterial.
  ///
  /// In en, this message translates to:
  /// **'Add Material'**
  String get addMaterial;

  /// No description provided for @noMaterialsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No Materials Added Yet'**
  String get noMaterialsAddedYet;

  /// No description provided for @tapAddMaterialButton.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Add Material\' button to add your first material'**
  String get tapAddMaterialButton;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @areYouSureDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently deleted.'**
  String get areYouSureDeleteAccount;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted successfully.'**
  String get accountDeletedSuccessfully;

  /// No description provided for @errorDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account. Please try again later.'**
  String get errorDeletingAccount;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @areYouSureDeleteMaterial.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this material?'**
  String get areYouSureDeleteMaterial;

  /// No description provided for @materialDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Material deleted successfully'**
  String get materialDeletedSuccessfully;

  /// No description provided for @errorLoadingMaterials.
  ///
  /// In en, this message translates to:
  /// **'Error loading materials'**
  String get errorLoadingMaterials;

  /// No description provided for @materialsSummary.
  ///
  /// In en, this message translates to:
  /// **'Materials Summary'**
  String get materialsSummary;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @filesAttached.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 file attached} other {{count} files attached}}'**
  String filesAttached(int count);

  /// No description provided for @materialsNote.
  ///
  /// In en, this message translates to:
  /// **'Materials Note'**
  String get materialsNote;

  /// No description provided for @materialsNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add notes about materials...'**
  String get materialsNotePlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
