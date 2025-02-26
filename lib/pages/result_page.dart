import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:unshooler_ai/components/constants.dart';

import '../components/api.dart';
import '../components/ui.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool isLoad = true;
  String newResult = "";
  AppConstants constants = AppConstants();

  @override
  Widget build(BuildContext context) {
    final Map result = ModalRoute.of(context)!.settings.arguments as Map;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    AppUi appUi = AppUi(context: context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.result_page_title,
            ),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close_rounded,
              ),
              tooltip: AppLocalizations.of(context)!.back_tooltip,
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 16,
                      //     vertical: 12,
                      //   ),
                      //   child: Text(
                      //     result["question"],
                      //     style: const TextStyle(
                      //       color: Colors.white,
                      //       fontWeight: FontWeight.w400,
                      //       fontSize: 18,
                      //       height: 1.5,
                      //     ),
                      //   ),
                      // ),
                      // Container(
                      //   margin: const EdgeInsets.symmetric(vertical: 24),
                      //   width: width,
                      //   height: 2,
                      //   color: Colors.white,
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: MarkdownBody(
                          data: newResult == "" ? result["result"] : newResult,
                          styleSheet:
                              MarkdownStyleSheet.fromTheme(Theme.of(context))
                                  .copyWith(
                            textScaleFactor: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    //TODO Explain Again Button
                    // FloatingActionButton.extended(
                    //   onPressed: () => explainAgain(appUi, result),
                    //   backgroundColor: Colors.transparent,
                    //   icon: Transform.scale(
                    //     scaleX: -1,
                    //     child: const Icon(
                    //       Icons.refresh,
                    //       size: 28,
                    //     ),
                    //   ),
                    //   label: Text(
                    //     AppLocalizations.of(context)!.explain_again_button,
                    //   ),
                    // ),
                    // const Spacer(),
                    FloatingActionButton(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                      ),
                      onPressed: () async => await Clipboard.setData(
                        ClipboardData(
                          text: result["result"],
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                      child: const Icon(
                        Icons.copy_rounded,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    FloatingActionButton(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      backgroundColor: constants.accent,
                      child: const Icon(
                        Icons.add_rounded,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        appUi.getLoading(width, height, isLoad),
      ],
    );
  }

  void explainAgain(AppUi appUi, Map arg) async {
    setState(
      () {
        isLoad = false;
      },
    );
    try {
      String result = await AppApi(context: context).getResult(arg["question"]);
      setState(() {
        newResult = result;
      });
    } catch (e) {
      appUi.buildSnackBar(
        message: AppLocalizations.of(context)!.unknown_error,
        errorEnabled: true,
      );
    } finally {
      setState(
        () {
          isLoad = true;
        },
      );
    }
  }
}
