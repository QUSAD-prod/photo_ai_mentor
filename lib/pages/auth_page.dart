import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unshooler_ai/components/demo.dart';
import 'package:unshooler_ai/l10n/app_localizations.dart';
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -width * 0.55,
            left: -width * 0.3,
            right: -width * 0.3,
            child: Container(
              height: width * 1.5,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    constants.accent.withValues(alpha: 0.45),
                    constants.accent.withValues(alpha: 0.12),
                    constants.background.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: constants.accentGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: constants.accent.withValues(alpha: 0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            "assets/auth_page_icon.svg",
                            width: width * 0.14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: constants.border),
                          ),
                          child: Text(
                            'Unschooler AI · ${l10n.auth_badge}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: constants.accentLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.auth_title,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.auth_subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: constants.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        getFeature(Icons.photo_camera_rounded, l10n.auth_feature_photo),
                        getFeature(Icons.format_list_numbered_rounded, l10n.auth_feature_steps),
                        getFeature(Icons.school_rounded, l10n.auth_feature_subjects),
                      ],
                    ),
                  ),
                  appUi.getAuthPageButton(
                    width,
                    l10n.google_login,
                    "assets/auth_page_google_icon.svg",
                    kDemoMode ? () => Navigator.of(context).pushReplacementNamed('/homePage') : login,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: constants.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: constants.border),
            ),
            child: Icon(icon, size: 18, color: constants.accentLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void login() {
    fb.googleLogin(
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
    );
  }
}
