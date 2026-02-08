// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get hello => 'Hello!';

  @override
  String welcome(Object name) {
    return 'Welcome, $name!';
  }

  @override
  String get authTitle => 'Sign in';

  @override
  String get authSubtitle => 'University report system';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'sample@mtuci.edu';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authInvalidEmail => 'Enter a valid email.';

  @override
  String get authUnknownEmail => 'This email is not in the mock database.';

  @override
  String get authDemoEmails => 'Demo emails: student@mtuci.edu, teacher@mtuci.edu';

  @override
  String get authCodeTitle => 'Enter code';

  @override
  String authCodeSubtitle(Object email) {
    return 'We sent a code to $email';
  }

  @override
  String get authCodeLabel => 'Code';

  @override
  String get authCodeHint => '123456';

  @override
  String get authVerifyCode => 'Verify code';

  @override
  String get authResendCode => 'Resend code';

  @override
  String get authResentMessage => 'Code sent again.';

  @override
  String get authInvalidCode => 'Invalid code. Try 123456.';

  @override
  String authDemoCode(Object code) {
    return 'Demo code: $code';
  }

  @override
  String get authSuccessTitle => "You're in";

  @override
  String authSuccessSubtitle(Object name) {
    return 'Welcome, $name!';
  }

  @override
  String get authContinue => 'Continue';

  @override
  String get homeTitle => 'Home';

  @override
  String homeSubtitle(Object role) {
    return 'Mock user role: $role';
  }

  @override
  String get reportAppTitle => 'University Reporting App';

  @override
  String get reportListTitle => 'Reports';

  @override
  String get reportFilterAll => 'All';

  @override
  String get reportListEmpty => 'No reports found.';

  @override
  String get reportCreateButton => 'Report a problem';

  @override
  String get reportStatusNew => 'New';

  @override
  String get reportStatusInProgress => 'In progress';

  @override
  String get reportStatusResolved => 'Resolved';

  @override
  String get reportDetailTitle => 'Report details';

  @override
  String get reportDetailLocation => 'Location';

  @override
  String get reportDetailRoom => 'Room';

  @override
  String get reportDetailCategory => 'Category';

  @override
  String get reportDetailPriority => 'Priority';

  @override
  String get reportDetailReporter => 'Reporter';

  @override
  String get reportDetailDate => 'Date';

  @override
  String get reportNotFound => 'Report not found.';

  @override
  String get reportDialogTitle => 'Report a problem';

  @override
  String get reportDialogTopic => 'Topic';

  @override
  String get reportDialogTopicHint => 'Short issue title';

  @override
  String get reportDialogLocation => 'Location';

  @override
  String get reportDialogLocationHint => 'Building, floor, room';

  @override
  String get reportDialogCategory => 'Category';

  @override
  String get reportDialogCategoryHint => 'Electricity, plumbing, etc.';

  @override
  String get reportDialogDescription => 'Description';

  @override
  String get reportDialogDescriptionHint => 'Describe the issue briefly';

  @override
  String get reportDialogSubmit => 'Send';

  @override
  String get reportDialogSuccess => 'Report submitted (mock).';
}
