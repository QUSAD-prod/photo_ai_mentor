import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unshooler_ai/components/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppUi {
  AppUi({required this.context});
  final BuildContext context;
  final AppConstants constants = AppConstants();

  Widget getLoading(double width, double height, bool isLoad) {
    return isLoad
        ? Container()
        : Container(
            width: width,
            height: height,
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SpinKitThreeBounce(
                    size: 24,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.loading,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }

  void buildSnackBar({required String message, bool errorEnabled = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 12.0,
      ),
      padding: errorEnabled
          ? const EdgeInsets.only(
              left: 12.0,
              right: 16.0,
              top: 12.0,
              bottom: 12.0,
            )
          : const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
      content: Row(
        children: [
          Container(
            margin: errorEnabled
                ? const EdgeInsets.only(right: 12.0)
                : const EdgeInsets.all(0.0),
            child: errorEnabled
                ? const Icon(
                    Icons.cancel,
                    color: Color(0xFFE7522E),
                  )
                : const SizedBox(),
          ),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget getAuthPageButton(
    double width,
    String text,
    String iconPath,
    void Function()? onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.21,
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            Colors.white,
          ),
          elevation: MaterialStateProperty.all<double>(
            0.0,
          ),
          foregroundColor: MaterialStateProperty.all<Color>(
            constants.background,
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.all(12.0),
          ),
          overlayColor: MaterialStateProperty.all<Color>(
            Colors.black.withOpacity(0.25),
          ),
        ),
        child: SizedBox(
          width: width * 0.75,
          child: Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: 28,
                height: 28,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12, right: 40),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
