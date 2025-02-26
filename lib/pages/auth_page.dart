import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unshooler_ai/components/constants.dart';
import 'package:unshooler_ai/components/fb.dart';
import 'package:unshooler_ai/components/ui.dart';

import '../components/api.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  AppConstants constants = AppConstants();
  late final AppFB fb;
  late final AppApi api;

  @override
  void initState() {
    fb = AppFB(context: context);
    api = AppApi(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    AppUi appUi = AppUi(context: context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SvgPicture.asset(
                  "assets/auth_page_icon.svg",
                  width: width * 0.44,
                ),
              ),
            ),
            appUi.getAuthPageButton(
              width,
              AppLocalizations.of(context)!.google_login,
              "assets/auth_page_google_icon.svg",
              () => fb.googleLogin(
                () async {
                  try {
                    int? id1 = await api.getUserId();
                    debugPrint(
                      "UserId: $id1",
                    );
                    if (id1 == null) {
                      await fb.auth.currentUser!.reload();
                      User? user = fb.auth.currentUser;
                      debugPrint(user.toString());
                      int? id2 = await api.createUser(
                        {
                          "userData": {
                            "name": user?.displayName,
                            "email": user?.email,
                            "googleUid": user?.uid,
                            "picture": user?.photoURL,
                          }
                        },
                      );
                      debugPrint(
                        "UserId: $id2",
                      );
                    }
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
