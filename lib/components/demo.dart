import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

// The backend (back.unschooler.me) is no longer available, so by default the
// app runs against canned data. Pass --dart-define=DEMO_MODE=false to use the
// real API again.
const bool kDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: true);

// Screenshot helpers, read from Documents/demo.json, e.g.
// {"screen": "home", "locale": "en"}. screen opens a specific page
// (auth, home, text, scan, result); locale forces the UI language.
Map<String, dynamic> _demoConfig = {};

String? get demoScreen => _demoConfig['screen'];
String? get demoLocale => _demoConfig['locale'];

Future<void> loadDemoConfig() async {
  if (!kDemoMode) return;
  try {
    final File file = File('${(await getApplicationDocumentsDirectory()).path}/demo.json');
    if (await file.exists()) _demoConfig = jsonDecode(await file.readAsString());
  } catch (e) {
    debugPrint(e.toString());
  }
}

class DemoData {
  static const Duration latency = Duration(milliseconds: 1400);

  static String problem(String languageCode) => languageCode == 'ru'
      ? 'Решите уравнение:\n2x²\u00A0−\u00A07x\u00A0+\u00A03\u00A0=\u00A00'
      : 'Solve the equation:\n2x²\u00A0−\u00A07x\u00A0+\u00A03\u00A0=\u00A00';

  static List<String> examples(String languageCode) => languageCode == 'ru'
      ? const [
          'Решите уравнение 2x²\u00A0−\u00A07x\u00A0+\u00A03\u00A0=\u00A00',
          'Почему небо голубое?',
          'Найдите производную sin(x)·x²',
        ]
      : const [
          'Solve 2x²\u00A0−\u00A07x\u00A0+\u00A03\u00A0=\u00A00',
          'Why is the sky blue?',
          'Differentiate sin(x)·x²',
        ];

  static String answer(String languageCode) => languageCode == 'ru' ? _answerRu : _answerEn;

  static const String _answerRu = '''
### 1. Определим коэффициенты
Уравнение вида **ax² + bx + c = 0**, где a\u00A0=\u00A02, b\u00A0=\u00A0−7, c\u00A0=\u00A03.

### 2. Найдём дискриминант
D = b² − 4ac = 49 − 24 = **25**. D > 0, значит у уравнения **два корня**.

### 3. Вычислим корни
x = (−b ± √D) / 2a = (7 ± 5) / 4

- x₁ = 12 / 4 = **3**
- x₂ = 2 / 4 = **0.5**

> **Ответ:** x₁ = 3, x₂ = 0.5
''';

  static const String _answerEn = '''
### 1. Identify the coefficients
The equation has the form **ax² + bx + c = 0**, where a\u00A0=\u00A02, b\u00A0=\u00A0−7, c\u00A0=\u00A03.

### 2. Compute the discriminant
D = b² − 4ac = 49 − 24 = **25**. D > 0, so there are **two real roots**.

### 3. Find the roots
x = (−b ± √D) / 2a = (7 ± 5) / 4

- x₁ = 12 / 4 = **3**
- x₂ = 2 / 4 = **0.5**

> **Answer:** x₁ = 3, x₂ = 0.5
''';
}
