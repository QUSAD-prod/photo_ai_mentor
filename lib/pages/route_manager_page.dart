import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unshooler_ai/components/demo.dart';
import 'package:unshooler_ai/components/fb.dart';
import 'package:unshooler_ai/pages/auth_page.dart';
import 'package:unshooler_ai/pages/home_page.dart';
import 'package:unshooler_ai/pages/result_page.dart';

class RouteManagerPage extends StatefulWidget {
  const RouteManagerPage({super.key});

  @override
  State<RouteManagerPage> createState() => _RouteManagerPageState();
}

class _RouteManagerPageState extends State<RouteManagerPage> {
  late final AppFB fb;
  late User? user;

  @override
  void initState() {
    fb = AppFB(context: context);
    user = fb.auth.currentUser;
    fb.auth.authStateChanges().listen(
      (User? user) {
        if (!mounted) return;
        setState(
          () {
            this.user = user;
          },
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Widget? demo = getDemoScreen(context);
    if (demo != null) return demo;
    return user == null ? const AuthPage() : const HomePage();
  }

  Widget? getDemoScreen(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    switch (demoScreen) {
      case 'auth':
        return const AuthPage();
      case 'home':
        return const HomePage();
      case 'scan':
        return const HomePage(autoScan: true);
      case 'text':
        return HomePage(initialTab: 1, initialText: DemoData.examples(languageCode).first);
      case 'result':
        return ResultPage(
          arguments: {
            "question": DemoData.problem(languageCode).replaceAll('\n', ' '),
            "result": DemoData.answer(languageCode),
          },
        );
    }
    return null;
  }
}
