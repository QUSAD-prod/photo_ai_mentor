import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unshooler_ai/components/constants.dart';

class AppUi {
  AppUi({required this.context});
  final BuildContext context;
  final AppConstants constants = AppConstants();

  Widget getLoading(double width, double height, bool isLoad, {required String message}) {
    return IgnorePointer(
      ignoring: isLoad,
      child: AnimatedOpacity(
        opacity: isLoad ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: width,
              height: height,
              color: constants.background.withValues(alpha: 0.6),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  decoration: BoxDecoration(
                    color: constants.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: constants.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SpinKitThreeBounce(
                        size: 22,
                        color: constants.accentLight,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            height: 1.4,
                          ),
                          child: Text(message),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void buildSnackBar({required String message, bool errorEnabled = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: constants.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: constants.border),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 14.0,
        horizontal: 16.0,
      ),
      content: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Icon(
              errorEnabled ? Icons.error_rounded : Icons.check_circle_rounded,
              color: errorEnabled ? constants.accent : const Color(0xFF4ADE80),
            ),
          ),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all<TextStyle>(
            const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              height: 1.2,
            ),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
          elevation: WidgetStateProperty.all<double>(0.0),
          foregroundColor: WidgetStateProperty.all<Color>(constants.background),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          ),
          overlayColor: WidgetStateProperty.all<Color>(
            Colors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget primaryButton({
    required String text,
    required void Function() onPressed,
    IconData icon = Icons.auto_awesome_rounded,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: constants.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: constants.accent.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.2),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget glassButton({
    required IconData icon,
    required String tooltip,
    required void Function() onPressed,
    double size = 52,
    bool active = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.14),
            shape: CircleBorder(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(
                  icon,
                  color: active ? constants.background : Colors.white,
                  size: size * 0.44,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: constants.surface,
      contentPadding: const EdgeInsets.all(18),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: constants.accentLight, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: constants.border, width: 1.0),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget sectionLabel(String text, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null)
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: constants.accentGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
        Text(
          text,
          style: TextStyle(
            color: icon != null ? Colors.white : constants.textSecondary,
            fontWeight: icon != null ? FontWeight.w700 : FontWeight.w600,
            fontSize: icon != null ? 18 : 13,
            letterSpacing: icon != null ? 0 : 0.6,
          ),
        ),
      ],
    );
  }
}
