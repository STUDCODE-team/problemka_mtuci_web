// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SRu extends S {
  SRu([String locale = 'ru']) : super(locale);

  @override
  String get hello => 'Привет!';

  @override
  String welcome(Object name) {
    return 'Добро пожаловать, $name!';
  }

  @override
  String get authTitle => 'Вход';

  @override
  String get authSubtitle => 'Система отчетов университета МТУСИ';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'sample@mtuci.edu';

  @override
  String get authSendCode => 'Отправить код';

  @override
  String get authInvalidEmail => 'Введите корректный email.';

  @override
  String get authUnknownEmail => 'Этого email нет в моковой базе.';

  @override
  String get authDemoEmails => 'Демо email: student@mtuci.edu, teacher@mtuci.edu';

  @override
  String get authCodeTitle => 'Введите код';

  @override
  String authCodeSubtitle(Object email) {
    return 'Мы отправили код на $email';
  }

  @override
  String get authCodeLabel => 'Код';

  @override
  String get authCodeHint => '123456';

  @override
  String get authVerifyCode => 'Проверить код';

  @override
  String get authResendCode => 'Отправить код еще раз';

  @override
  String get authResentMessage => 'Код отправлен повторно.';

  @override
  String get authInvalidCode => 'Неверный код. Попробуйте 123456.';

  @override
  String authDemoCode(Object code) {
    return 'Демо код: $code';
  }

  @override
  String get authSuccessTitle => 'Готово';

  @override
  String authSuccessSubtitle(Object name) {
    return 'Добро пожаловать, $name!';
  }

  @override
  String get authContinue => 'Продолжить';

  @override
  String get homeTitle => 'Главная';

  @override
  String homeSubtitle(Object role) {
    return 'Роль пользователя (mock): $role';
  }

  @override
  String get reportAppTitle => 'University Reporting App';

  @override
  String get reportListTitle => 'Отчеты';

  @override
  String get reportFilterAll => 'Все';

  @override
  String get reportListEmpty => 'Отчетов пока нет.';

  @override
  String get reportCreateButton => 'Сообщить о проблеме';

  @override
  String get reportStatusNew => 'Новое';

  @override
  String get reportStatusInProgress => 'В работе';

  @override
  String get reportStatusResolved => 'Решено';

  @override
  String get reportDetailTitle => 'Детали отчета';

  @override
  String get reportDetailLocation => 'Место';

  @override
  String get reportDetailRoom => 'Кабинет';

  @override
  String get reportDetailCategory => 'Категория';

  @override
  String get reportDetailPriority => 'Приоритет';

  @override
  String get reportDetailReporter => 'Автор';

  @override
  String get reportDetailDate => 'Дата';

  @override
  String get reportNotFound => 'Отчет не найден.';

  @override
  String get reportDialogTitle => 'Сообщить о проблеме';

  @override
  String get reportDialogTopic => 'Заголовок';

  @override
  String get reportDialogTopicHint => 'Краткое название';

  @override
  String get reportDialogLocation => 'Расположение';

  @override
  String get reportDialogLocationHint => 'Корпус, этаж, кабинет';

  @override
  String get reportDialogCategory => 'Категория';

  @override
  String get reportDialogCategoryHint => 'Электрика, сантехника и т.д.';

  @override
  String get reportDialogDescription => 'Описание';

  @override
  String get reportDialogDescriptionHint => 'Опишите проблему';

  @override
  String get reportDialogSubmit => 'Отправить';

  @override
  String get reportDialogSuccess => 'Отчет отправлен (mock).';
}
