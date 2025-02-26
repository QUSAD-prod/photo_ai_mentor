import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unshooler_ai/components/fb.dart';
import 'package:unshooler_ai/pages/auth_page.dart';
import 'package:unshooler_ai/pages/home_page.dart';

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
    return user == null ? const AuthPage() : const HomePage();
  }
}
