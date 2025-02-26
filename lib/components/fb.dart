import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unshooler_ai/components/ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppFB {
  AppFB({required this.context});
  final BuildContext context;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> googleLogin(void Function() func) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential).then(
              (value) => func(),
            );
      }
    } catch (e) {
      AppUi(context: context).buildSnackBar(
        message: AppLocalizations.of(context)!.unknown_error,
        errorEnabled: true,
      );
      debugPrint(e.toString());
    }
  }
}
