import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unshooler_ai/components/ui.dart';
import 'package:unshooler_ai/l10n/app_localizations.dart';

class AppFB {
  AppFB({required this.context});
  final BuildContext context;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> googleLogin(void Function() func) async {
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential).then(
            (value) => func(),
          );
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) _showError(e);
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object e) {
    if (!context.mounted) return;
    AppUi(context: context).buildSnackBar(
      message: AppLocalizations.of(context)!.unknown_error,
      errorEnabled: true,
    );
    debugPrint(e.toString());
  }
}
