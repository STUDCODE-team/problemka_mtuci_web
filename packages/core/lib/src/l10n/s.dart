import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 's_en.dart';
import 's_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/s.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcome(Object name);

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'University report system'**
  String get authSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'sample@mtuci.edu'**
  String get authEmailHint;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get authInvalidEmail;

  /// No description provided for @authUnknownEmail.
  ///
  /// In en, this message translates to:
  /// **'This email is not in the mock database.'**
  String get authUnknownEmail;

  /// No description provided for @authDemoEmails.
  ///
  /// In en, this message translates to:
  /// **'Demo emails: student@mtuci.edu, teacher@mtuci.edu'**
  String get authDemoEmails;

  /// No description provided for @authCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get authCodeTitle;

  /// No description provided for @authCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {email}'**
  String authCodeSubtitle(Object email);

  /// No description provided for @authCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get authCodeLabel;

  /// No description provided for @authCodeHint.
  ///
  /// In en, this message translates to:
  /// **'123456'**
  String get authCodeHint;

  /// No description provided for @authVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get authVerifyCode;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResendCode;

  /// No description provided for @authResentMessage.
  ///
  /// In en, this message translates to:
  /// **'Code sent again.'**
  String get authResentMessage;

  /// No description provided for @authInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Try 123456.'**
  String get authInvalidCode;

  /// No description provided for @authDemoCode.
  ///
  /// In en, this message translates to:
  /// **'Demo code: {code}'**
  String authDemoCode(Object code);

  /// No description provided for @authSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'You're in'**
  String get authSuccessTitle;

  /// No description provided for @authSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String authSuccessSubtitle(Object name);

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mock user role: {role}'**
  String homeSubtitle(Object role);

  /// No description provided for @reportAppTitle.
  ///
  /// In en, this message translates to:
  /// **'University Reporting App'**
  String get reportAppTitle;

  /// No description provided for @reportListTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportListTitle;

  /// No description provided for @reportFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get reportFilterAll;

  /// No description provided for @reportListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reports found.'**
  String get reportListEmpty;

  /// No description provided for @reportCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportCreateButton;

  /// No description provided for @reportStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get reportStatusNew;

  /// No description provided for @reportStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get reportStatusInProgress;

  /// No description provided for @reportStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get reportStatusResolved;

  /// No description provided for @reportDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Report details'**
  String get reportDetailTitle;

  /// No description provided for @reportDetailLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get reportDetailLocation;

  /// No description provided for @reportDetailRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get reportDetailRoom;

  /// No description provided for @reportDetailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get reportDetailCategory;

  /// No description provided for @reportDetailPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get reportDetailPriority;

  /// No description provided for @reportDetailReporter.
  ///
  /// In en, this message translates to:
  /// **'Reporter'**
  String get reportDetailReporter;

  /// No description provided for @reportDetailDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reportDetailDate;

  /// No description provided for @reportNotFound.
  ///
  /// In en, this message translates to:
  /// **'Report not found.'**
  String get reportNotFound;

  /// No description provided for @reportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportDialogTitle;

  /// No description provided for @reportDialogTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get reportDialogTopic;

  /// No description provided for @reportDialogTopicHint.
  ///
  /// In en, this message translates to:
  /// **'Short issue title'**
  String get reportDialogTopicHint;

  /// No description provided for @reportDialogLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get reportDialogLocation;

  /// No description provided for @reportDialogLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Building, floor, room'**
  String get reportDialogLocationHint;

  /// No description provided for @reportDialogCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get reportDialogCategory;

  /// No description provided for @reportDialogCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Electricity, plumbing, etc.'**
  String get reportDialogCategoryHint;

  /// No description provided for @reportDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reportDialogDescription;

  /// No description provided for @reportDialogDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue briefly'**
  String get reportDialogDescriptionHint;

  /// No description provided for @reportDialogSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get reportDialogSubmit;

  /// No description provided for @reportDialogSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted (mock).'**
  String get reportDialogSuccess;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'ru':
      return SRu();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
