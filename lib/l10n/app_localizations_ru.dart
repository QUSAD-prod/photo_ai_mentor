// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get photo => 'Фото';

  @override
  String get text => 'Текст';

  @override
  String get settings_tooltip => 'Настройки';

  @override
  String get settings_appbar_title => 'Настройки';

  @override
  String get back_tooltip => 'Назад';

  @override
  String get close_tooltip => 'Закрыть';

  @override
  String get text_hint => 'Введите свой вопрос...';

  @override
  String get explain_it_button => 'Решить это';

  @override
  String get the_minimum_number_error => 'Минимальное кол-во символов 10';

  @override
  String get unknown_error => 'Неизвестная ошибка';

  @override
  String get result_page_title => 'Результат';

  @override
  String get explain_again_button => 'Решить снова';

  @override
  String get google_login => 'Войти через Google';

  @override
  String get google_login_error => 'Неизвестная ошибка';

  @override
  String get loading => 'Решаем… это займёт пару секунд';

  @override
  String get recognizing => 'Распознаём задачу…';

  @override
  String get your_request => 'Ваш вопрос';

  @override
  String get auth_badge => 'ИИ-наставник по учёбе';

  @override
  String get auth_title => 'Сфотографируй задачу —\nполучи понятное решение';

  @override
  String get auth_subtitle =>
      'Наведите камеру на любое задание: ИИ прочитает условие и разберёт решение по шагам.';

  @override
  String get auth_feature_photo => 'Фото или текстовый ввод';

  @override
  String get auth_feature_steps => 'Пошаговые объяснения';

  @override
  String get auth_feature_subjects => 'Математика, физика, химия и не только';

  @override
  String get camera_hint => 'Поместите задачу в рамку';

  @override
  String get flash_tooltip => 'Вспышка';

  @override
  String get keyboard_tooltip => 'Ввести текстом';

  @override
  String get text_title => 'Задайте вопрос';

  @override
  String get text_subtitle =>
      'Напишите задачу или вопрос — ИИ разберёт её по шагам.';

  @override
  String get examples_title => 'Попробуйте пример';

  @override
  String get recognized_title => 'Проверьте распознанный текст';

  @override
  String get solution_title => 'Пошаговое решение';

  @override
  String get new_question => 'Новый вопрос';

  @override
  String get copy_tooltip => 'Копировать';

  @override
  String get copied => 'Скопировано';
}
