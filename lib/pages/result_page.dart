import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unshooler_ai/l10n/app_localizations.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:unshooler_ai/components/constants.dart';

import '../components/api.dart';
import '../components/ui.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, this.arguments});

  // Used when the page is opened directly instead of through a named route.
  final Map? arguments;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool isLoad = true;
  String newResult = "";
  AppConstants constants = AppConstants();

  @override
  Widget build(BuildContext context) {
    final Map result = widget.arguments ?? ModalRoute.of(context)!.settings.arguments as Map;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    AppUi appUi = AppUi(context: context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            title: Text(
              l10n.result_page_title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.close_rounded,
              ),
              tooltip: l10n.back_tooltip,
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: constants.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: constants.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            appUi.sectionLabel(l10n.your_request.toUpperCase()),
                            const SizedBox(height: 8),
                            Text(
                              result["question"],
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 4),
                        child: appUi.sectionLabel(l10n.solution_title, icon: Icons.auto_awesome_rounded),
                      ),
                      MarkdownBody(
                        data: newResult == "" ? result["result"] : newResult,
                        styleSheet: getStyleSheet(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).viewPadding.bottom),
                decoration: BoxDecoration(
                  color: constants.background,
                  border: Border(top: BorderSide(color: constants.border)),
                ),
                child: Row(
                  children: [
                    appUi.glassButton(
                      icon: Icons.copy_rounded,
                      tooltip: l10n.copy_tooltip,
                      size: 56,
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text: newResult == "" ? result["result"] : newResult,
                          ),
                        );
                        if (!context.mounted) return;
                        AppUi(context: context).buildSnackBar(message: l10n.copied);
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: appUi.primaryButton(
                        text: l10n.new_question,
                        icon: Icons.add_rounded,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        appUi.getLoading(width, height, isLoad, message: l10n.loading),
      ],
    );
  }

  MarkdownStyleSheet getStyleSheet() {
    const TextStyle body = TextStyle(
      color: Color(0xE6FFFFFF),
      fontSize: 16,
      height: 1.55,
    );
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: body,
      listBullet: body,
      strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      h3: TextStyle(
        color: constants.accentLight,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.4,
      ),
      h3Padding: const EdgeInsets.only(top: 14),
      blockSpacing: 10,
      code: TextStyle(
        color: const Color(0xFFFFC9A8),
        backgroundColor: constants.surfaceHigh,
        fontFamily: 'Courier',
        fontSize: 15,
      ),
      blockquotePadding: const EdgeInsets.all(16),
      blockquoteDecoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            constants.accent.withValues(alpha: 0.22),
            constants.accent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: constants.accent.withValues(alpha: 0.4)),
      ),
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
      if (!mounted) return;
      appUi.buildSnackBar(
        message: AppLocalizations.of(context)!.unknown_error,
        errorEnabled: true,
      );
    } finally {
      if (mounted) {
        setState(
          () {
            isLoad = true;
          },
        );
      }
    }
  }
}
