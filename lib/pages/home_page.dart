import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:unshooler_ai/components/api.dart';
import 'package:unshooler_ai/components/demo.dart';
import 'package:unshooler_ai/components/scanner.dart';
import 'package:unshooler_ai/l10n/app_localizations.dart';
import '../components/constants.dart';
import '../components/ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialTab = 0, this.autoScan = false, this.initialText = ''});

  final int initialTab;

  // Takes a picture as soon as the camera is ready (used for demo screenshots).
  final bool autoScan;
  final String initialText;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _controller;
  late TabController _tabController;
  late TextEditingController _textController;
  late TextEditingController _modalPageTextFieldController;
  late AnimationController _scanController;
  final GlobalKey _previewKey = GlobalKey();
  bool isLoad = false;
  bool hasCamera = true;
  bool isLoadSending = true;
  bool modalLoading = false;
  bool isModalPageOpened = false;
  bool isFlashOn = false;
  String loadingMessage = '';
  AppConstants constants = AppConstants();

  double cropXKoeff = 0.85;
  double cropYKoeff = 0.2;

  final double cropXKoeffMax = 0.9;
  final double cropYKoeffMax = 0.4;

  final double cropXKoeffMin = 0.5;
  final double cropYKoeffMin = 0.1;

  // Vertical centre of the crop frame as a fraction of the screen height.
  static const double cropCenterY = 0.38;

  double dragXStart = 0;
  double dragYStart = 0;

  bool isChangeKoeff = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _modalPageTextFieldController = TextEditingController();
    _textController = TextEditingController(text: widget.initialText);
    _tabController = TabController(
      initialIndex: widget.initialTab,
      vsync: this,
      length: 2,
    );
    _tabController.animation?.addListener(
      () => setState(
        () {
          FocusScope.of(context).unfocus();
        },
      ),
    );
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
      value: 0.12,
    );
    if (demoScreen == null) _scanController.repeat(reverse: true);

    initCamera();
  }

  Future<void> initCamera() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('noCamera', 'No cameras available');
      final CameraController controller = CameraController(
        cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
      );
      _controller = controller;
      await controller.initialize();
    } catch (e) {
      // No camera (e.g. simulator): fall back to the demo scene in demo mode.
      debugPrint(e.toString());
      hasCamera = false;
    }
    if (!mounted) return;
    setState(() => isLoad = true);
    if (widget.autoScan) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => handleTakeImage(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _tabController.dispose();
    _textController.dispose();
    _modalPageTextFieldController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      setState(
        () => isLoad = false,
      );
      initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    AppUi appUi = AppUi(context: context);
    final double tabValue = _tabController.animation?.value ?? 0;

    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: constants.background.withValues(alpha: tabValue),
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 64,
            title: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: width * 0.62,
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      Colors.black.withValues(alpha: 0.35),
                      constants.surface,
                      tabValue,
                    ),
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.white,
                    ),
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    labelColor: constants.background,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.85),
                    splashBorderRadius: BorderRadius.circular(25.0),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_camera_rounded, size: 18),
                            const SizedBox(width: 6),
                            Text(AppLocalizations.of(context)!.photo),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit_note_rounded, size: 20),
                            const SizedBox(width: 6),
                            Text(AppLocalizations.of(context)!.text),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              getCamera(height, width),
              getText(height, width),
            ],
          ),
        ),
        appUi.getLoading(width, height, isLoadSending, message: loadingMessage),
      ],
    );
  }

  Rect cropFrame(double width, double height) {
    return Rect.fromCenter(
      center: Offset(width / 2, height * cropCenterY),
      width: width * cropXKoeff,
      height: height * cropYKoeff,
    );
  }

  Widget getPreview() {
    if (!isLoad) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
    final CameraController? controller = _controller;
    if (hasCamera && controller != null) {
      return CameraPreview(controller);
    }
    return DemoCameraScene(
      problem: DemoData.problem(Localizations.localeOf(context).languageCode),
      problemCenterY: cropCenterY,
    );
  }

  Widget getCamera(double height, double width) {
    final Rect frame = cropFrame(width, height);
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          key: _previewKey,
          child: getPreview(),
        ),
        CustomPaint(
          painter: ScannerOverlayPainter(
            frame: frame,
            dimColor: constants.background.withValues(alpha: 0.72),
            accent: constants.accent,
            scanProgress: _scanController,
            active: isChangeKoeff,
          ),
        ),
        Positioned.fromRect(
          rect: frame,
          child: GestureDetector(
            onPanStart: (details) {
              setState(
                () {
                  isChangeKoeff = true;
                },
              );
              dragXStart = details.globalPosition.dx.floorToDouble();
              dragYStart = details.globalPosition.dy.floorToDouble();
            },
            onPanUpdate: (details) => changeScale(details),
            onPanEnd: (details) => setState(
              () {
                isChangeKoeff = false;
              },
            ),
          ),
        ),
        Positioned(
          top: frame.top - 52,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.center_focus_strong_rounded, size: 16, color: constants.accentLight),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.camera_hint,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomInset + height * 0.1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppUi(context: context).glassButton(
                icon: isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                tooltip: AppLocalizations.of(context)!.flash_tooltip,
                active: isFlashOn,
                onPressed: toggleFlash,
              ),
              getShutterButton(width, height),
              AppUi(context: context).glassButton(
                icon: Icons.keyboard_alt_outlined,
                tooltip: AppLocalizations.of(context)!.keyboard_tooltip,
                onPressed: () => _tabController.animateTo(1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getShutterButton(double width, double height) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 4,
          color: Colors.white,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: constants.accentGradient,
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              color: constants.accent.withValues(alpha: 0.6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            splashColor: Colors.white.withValues(alpha: 0.5),
            onTap: () => handleTakeImage(width, height),
            child: const SizedBox(
              width: 64,
              height: 64,
              child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
    );
  }

  void toggleFlash() {
    setState(() => isFlashOn = !isFlashOn);
    _controller?.setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off).catchError((_) {});
  }

  void changeScale(DragUpdateDetails details) {
    double positionX = details.globalPosition.dx.floorToDouble() / dragXStart;
    double positionY = details.globalPosition.dy.floorToDouble() / dragYStart;

    if (cropXKoeff * positionX < cropXKoeffMax && cropXKoeff * positionX > cropXKoeffMin) {
      setState(
        () {
          cropXKoeff *= positionX;
        },
      );
    }

    if (cropYKoeff * positionY < cropYKoeffMax && cropYKoeff * positionY > cropYKoeffMin) {
      setState(
        () {
          cropYKoeff *= positionY;
        },
      );
    }

    dragXStart = details.globalPosition.dx.floorToDouble();
    dragYStart = details.globalPosition.dy.floorToDouble();
  }

  Future<File> cropImage(img.Image image) async {
    var cropImage = img.copyCrop(
      image,
      x: ((image.width - image.width * cropXKoeff) / 2).floor(),
      y: (image.height * cropCenterY - image.height * cropYKoeff / 2).floor(),
      width: (image.width * cropXKoeff).floor(),
      height: (image.height * cropYKoeff).floor(),
    );
    var bytes = img.encodeJpg(cropImage);

    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/cropImage_${DateTime.now().millisecondsSinceEpoch}.jpeg');

    await file.writeAsBytes(bytes);

    return file;
  }

  Future<img.Image> capture() async {
    final CameraController? controller = _controller;
    if (hasCamera && controller != null) {
      XFile xFile = await controller.takePicture();
      return img.decodeImage(await xFile.readAsBytes())!;
    }
    final RenderRepaintBoundary boundary = _previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image snapshot = await boundary.toImage(pixelRatio: 2);
    final bytes = await snapshot.toByteData(format: ui.ImageByteFormat.png);
    return img.decodePng(bytes!.buffer.asUint8List())!;
  }

  Future<String> recognizeText(File file) async {
    if (kDemoMode) {
      await Future.delayed(DemoData.latency);
      if (!mounted) return '';
      return DemoData.problem(Localizations.localeOf(context).languageCode).replaceAll('\n', ' ');
    }
    FormData formData = FormData.fromMap(
      {
        'file': await MultipartFile.fromFile(
          file.path,
          filename: 'test.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      },
    );
    Response response = await Dio().post(
      'https://back.unschooler.me/recognize_text',
      data: formData,
    );
    return response.data.toString();
  }

  void handleTakeImage(double width, double height) async {
    if (!isLoad) return;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(
      () {
        loadingMessage = l10n.recognizing;
        isLoadSending = false;
      },
    );

    try {
      File file = await cropImage(await capture());
      String text = await recognizeText(file);

      setState(
        () {
          _modalPageTextFieldController.text = text;
          isModalPageOpened = true;
          isLoadSending = true;
        },
      );
      if (!mounted) return;
      double topPadding = MediaQuery.of(context).viewPadding.top;
      imageCache.clear();
      await showModalBottomSheet(
        context: context,
        constraints: BoxConstraints.expand(
          width: width,
          height: height - topPadding,
        ),
        backgroundColor: constants.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        enableDrag: false,
        isScrollControlled: true,
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setModalState) => Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  centerTitle: false,
                  titleSpacing: 0,
                  title: Text(
                    AppLocalizations.of(context)!.recognized_title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  leading: IconButton(
                    onPressed: () {
                      setState(
                        () {
                          isModalPageOpened = false;
                        },
                      );
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                    tooltip: AppLocalizations.of(context)!.close_tooltip,
                  ),
                ),
                body: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: constants.border),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.file(file, fit: BoxFit.cover),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 24, bottom: 10, left: 4),
                                  child: AppUi(context: context).sectionLabel(
                                    AppLocalizations.of(context)!.your_request.toUpperCase(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: TextField(
                                    controller: _modalPageTextFieldController,
                                    minLines: 3,
                                    maxLines: 100,
                                    cursorColor: constants.accentLight,
                                    cursorRadius: const Radius.circular(5),
                                    style: const TextStyle(fontSize: 18, height: 1.5),
                                    decoration: AppUi(context: context).inputDecoration(
                                      AppLocalizations.of(context)!.text_hint,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8.0),
                          child: AppUi(context: context).primaryButton(
                            text: AppLocalizations.of(context)!.explain_it_button,
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setModalState(() => modalLoading = true);
                              send(
                                _modalPageTextFieldController.text,
                                onDone: () => setModalState(() => modalLoading = false),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppUi(context: context).getLoading(
                width,
                height,
                !modalLoading,
                message: AppLocalizations.of(context)!.loading,
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        AppUi(context: context).buildSnackBar(
          message: l10n.unknown_error,
          errorEnabled: true,
        );
      }
    } finally {
      if (mounted) {
        setState(
          () {
            isLoadSending = true;
          },
        );
      }
    }
  }

  Widget getText(double height, double width) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AppUi appUi = AppUi(context: context);

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.text_title,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        child: Text(
                          l10n.text_subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.45,
                            color: constants.textSecondary,
                          ),
                        ),
                      ),
                      TextField(
                        controller: _textController,
                        minLines: 5,
                        maxLines: 50,
                        cursorColor: constants.accentLight,
                        cursorRadius: const Radius.circular(5),
                        style: const TextStyle(fontSize: 18, height: 1.5),
                        decoration: appUi.inputDecoration(l10n.text_hint),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 28, bottom: 12, left: 4),
                        child: appUi.sectionLabel(l10n.examples_title.toUpperCase()),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final String example in DemoData.examples(Localizations.localeOf(context).languageCode))
                            getExampleChip(example),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: appUi.primaryButton(
                  text: l10n.explain_it_button,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    send(
                      _textController.text,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getExampleChip(String example) {
    return Material(
      color: constants.surface,
      shape: StadiumBorder(side: BorderSide(color: constants.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => setState(() => _textController.text = example),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.north_east_rounded, size: 14, color: constants.accentLight),
              const SizedBox(width: 6),
              Text(example, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  void send(String text, {void Function()? onDone}) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (text.length > 10) {
      FocusScope.of(context).unfocus();
      setState(
        () {
          loadingMessage = l10n.loading;
          isLoadSending = isModalPageOpened;
        },
      );
      try {
        String result = await AppApi(context: context).getResult(text);
        if (!mounted) return;
        setState(
          () {
            isLoadSending = true;
          },
        );
        onDone?.call();
        if (isModalPageOpened) {
          setState(
            () {
              isModalPageOpened = false;
              _modalPageTextFieldController.clear();
            },
          );
          Navigator.popAndPushNamed(
            context,
            "/resultPage",
            arguments: {
              "question": text,
              "result": result,
            },
          );
        } else {
          setState(() {
            _textController.clear();
          });
          Navigator.of(context).pushNamed(
            "/resultPage",
            arguments: {
              "question": text,
              "result": result,
            },
          );
        }
      } catch (e) {
        if (!mounted) return;
        AppUi(context: context).buildSnackBar(
          message: l10n.unknown_error,
          errorEnabled: true,
        );
        setState(
          () {
            isLoadSending = true;
          },
        );
        onDone?.call();
      }
    } else {
      AppUi(context: context).buildSnackBar(
        message: l10n.the_minimum_number_error,
        errorEnabled: true,
      );
      onDone?.call();
    }
  }
}
