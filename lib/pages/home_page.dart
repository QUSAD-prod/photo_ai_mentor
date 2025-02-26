import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' show encodeJpg, decodeImage, copyCrop;
import 'package:path_provider/path_provider.dart';
import 'package:unshooler_ai/components/api.dart';
import 'package:unshooler_ai/components/fb.dart';
import '../components/constants.dart';
import '../components/ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late CameraController _controller;
  late TabController _tabController;
  late TextEditingController _textController;
  late TextEditingController _modalPageTextFieldController;
  bool isLoad = false;
  bool isLoadSending = true;
  bool modalLoading = false;
  bool isModalPageOpened = false;
  AppConstants constants = AppConstants();
  late SvgPicture angle;

  double cropXKoeff = 0.85;
  double cropYKoeff = 0.2;

  final double cropXKoeffMax = 0.9;
  final double cropYKoeffMax = 0.4;

  final double cropXKoeffMin = 0.5;
  final double cropYKoeffMin = 0.1;

  double dragXStart = 0;
  double dragYStart = 0;

  bool isChangeKoeff = false;
  late final AppFB fb;

  @override
  void initState() {
    super.initState();
    fb = AppFB(context: context);
    _modalPageTextFieldController = TextEditingController();
    _textController = TextEditingController();
    _tabController = TabController(
      initialIndex: 0,
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
    angle = SvgPicture.asset("assets/angle.svg");

    availableCameras().then(
      (cameras) {
        _controller = CameraController(
          cameras[0],
          ResolutionPreset.max,
          enableAudio: false,
        );
        _controller.initialize().then(
          (value) {
            if (!mounted) {
              return;
            }
            setState(
              () => isLoad = true,
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      setState(
        () => isLoad = false,
      );
      availableCameras().then(
        (cameras) {
          _controller = CameraController(
            cameras[0],
            ResolutionPreset.max,
            enableAudio: false,
          );
          _controller.initialize().then(
            (value) {
              if (!mounted) {
                return;
              }
              setState(
                () => isLoad = true,
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    AppUi appUi = AppUi(context: context);

    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: constants.background
                .withOpacity(_tabController.animation?.value ?? 0),
            title: Container(
              width: width * 0.7,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Color.lerp(
                    constants.background,
                    Colors.white,
                    _tabController.animation?.value ?? 0,
                  ),
                ),
                labelStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                labelColor: Color.lerp(
                  Colors.white,
                  Colors.black,
                  _tabController.animation?.value ?? 0,
                ),
                unselectedLabelColor: Colors.white,
                splashBorderRadius: BorderRadius.circular(25.0),
                tabs: [
                  Tab(
                    text: AppLocalizations.of(context)!.photo,
                  ),
                  Tab(
                    text: AppLocalizations.of(context)!.text,
                  ),
                ],
              ),
            ),
            //TODO Settings Button

            // leading: IconButton(
            //   onPressed: () => Navigator.of(context).pushNamed('/settingsPage'),
            //   icon: const Icon(
            //     Icons.settings,
            //   ),
            //   tooltip: AppLocalizations.of(context)!.settings_tooltip,
            // ),
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
        appUi.getLoading(width, height, isLoadSending),
      ],
    );
  }

  Widget getCamera(double height, double width) {
    return Stack(
      fit: StackFit.expand,
      children: [
        isLoad
            ? CameraPreview(_controller)
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            constants.background.withOpacity(0.75),
            BlendMode.srcOut,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  margin: EdgeInsets.only(
                    top: height * 0.35 - height * cropYKoeff / 2,
                  ),
                  child: Container(
                    height: height * cropYKoeff - 4,
                    width: width * cropXKoeff - 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              GestureDetector(
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
                child: Container(
                  margin: EdgeInsets.only(
                    top: height * 0.35 - height * cropYKoeff / 2,
                  ),
                  height: height * cropYKoeff,
                  width: width * cropXKoeff,
                  child: Column(
                    children: [
                      const Spacer(),
                      Row(
                        children: [
                          const Spacer(),
                          RotatedBox(
                            quarterTurns: 2,
                            child: angle,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(
                  bottom: height * 0.1,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      width: 4,
                      color: constants.accent.withOpacity(0.35),
                    ),
                  ),
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                            color: Colors.black.withOpacity(0.25),
                          ),
                        ],
                      ),
                      child: Material(
                        color: constants.accent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.5),
                          onTap: () => handleTakeImage(width, height),
                          child: SizedBox(
                            width: width * 0.14,
                            height: width * 0.14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void changeScale(DragUpdateDetails details) {
    double positionX = details.globalPosition.dx.floorToDouble() / dragXStart;
    double positionY = details.globalPosition.dy.floorToDouble() / dragYStart;

    if (cropXKoeff * positionX < cropXKoeffMax &&
        cropXKoeff * positionX > cropXKoeffMin) {
      setState(
        () {
          cropXKoeff *= positionX;
        },
      );
    }

    if (cropYKoeff * positionY < cropYKoeffMax &&
        cropYKoeff * positionY > cropYKoeffMin) {
      setState(
        () {
          cropYKoeff *= positionY;
        },
      );
    }

    dragXStart = details.globalPosition.dx.floorToDouble();
    dragYStart = details.globalPosition.dy.floorToDouble();
  }

  Future<File> cropXFile(XFile xFile) async {
    var image = decodeImage(await xFile.readAsBytes())!;
    var cropImage = copyCrop(
      image,
      ((image.width - image.width * cropXKoeff) / 2).floor(),
      (image.height * 0.35 - image.height * cropYKoeff / 2).floor(),
      (image.width * cropXKoeff).floor(),
      (image.height * cropYKoeff).floor(),
    );
    var bytes = encodeJpg(cropImage);

    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/cropImage.jpeg');

    await file.writeAsBytes(bytes);

    return file;
  }

  void handleTakeImage(double width, double height) async {
    setState(
      () {
        isLoadSending = false;
      },
    );

    XFile xFile = await _controller.takePicture();
    File file = await cropXFile(xFile);

    try {
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

      setState(
        () {
          _modalPageTextFieldController.text = response.data.toString();
          isModalPageOpened = true;
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
        enableDrag: false,
        isScrollControlled: true,
        builder: (BuildContext context) => Stack(
          children: [
            Scaffold(
              appBar: AppBar(
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
                    Icons.cancel_rounded,
                  ),
                  tooltip: AppLocalizations.of(context)!.settings_tooltip,
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.file(file),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                AppLocalizations.of(context)!.your_request,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 1.7,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextField(
                                controller: _modalPageTextFieldController,
                                minLines: 10,
                                maxLines: 100,
                                cursorColor: Colors.white,
                                cursorRadius: const Radius.circular(5),
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.7),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  hintText:
                                      AppLocalizations.of(context)!.text_hint,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(
                            () {
                              FocusScope.of(context).unfocus();
                              modalLoading = true;
                            },
                          );
                          send(
                            _modalPageTextFieldController.text,
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            constants.accent,
                          ),
                          foregroundColor: MaterialStateProperty.all(
                            Colors.white,
                          ),
                          elevation: MaterialStateProperty.all(
                            0,
                          ),
                          shadowColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.explain_it_button,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                height: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppUi(context: context).getLoading(
              width,
              height,
              !modalLoading,
            ),
          ],
        ),
      );
    } catch (e) {
      if (e is DioError) {
        //handle DioError here by error type or by error code
      } else {}
    } finally {
      setState(
        () {
          isLoadSending = true;
        },
      );
    }
  }

  Widget getText(double height, double width) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _textController,
                    minLines: 10,
                    maxLines: 50,
                    cursorColor: Colors.white,
                    cursorRadius: const Radius.circular(5),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.7),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: AppLocalizations.of(context)!.text_hint,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(
                      () {
                        FocusScope.of(context).unfocus();
                        modalLoading = true;
                      },
                    );
                    send(
                      _textController.text,
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      constants.accent,
                    ),
                    foregroundColor: MaterialStateProperty.all(
                      Colors.white,
                    ),
                    elevation: MaterialStateProperty.all(
                      0,
                    ),
                    shadowColor: MaterialStateProperty.all(
                      Colors.transparent,
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.explain_it_button,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void send(String text) async {
    if (text.length > 10) {
      FocusScope.of(context).unfocus();
      setState(
        () {
          isLoadSending = false;
          modalLoading = true;
        },
      );
      try {
        String result = await AppApi(context: context).getResult(text);
        if (!mounted) return;
        setState(
          () {
            isLoadSending = true;
            modalLoading = false;
          },
        );
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
        AppUi(context: context).buildSnackBar(
          message: AppLocalizations.of(context)!.unknown_error,
          errorEnabled: true,
        );
        setState(
          () {
            isLoadSending = true;
            modalLoading = false;
          },
        );
      }
    } else {
      AppUi(context: context).buildSnackBar(
        message: AppLocalizations.of(context)!.the_minimum_number_error,
        errorEnabled: true,
      );
      setState(
        () {
          isLoadSending = true;
          modalLoading = false;
        },
      );
    }
  }
}
