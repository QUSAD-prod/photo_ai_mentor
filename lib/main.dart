import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:unshooler_ai/pages/auth_page.dart';
import 'package:unshooler_ai/pages/home_page.dart';
import 'package:unshooler_ai/pages/result_page.dart';
import 'package:unshooler_ai/pages/route_manager_page.dart';
import 'components/constants.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final HttpLink httpLink = HttpLink(
    'https://back.unschooler.me/',
  );

  final AuthLink authLink = AuthLink(
    getToken: () async {
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      return 'Bearer ${token ?? ''}';
    },
  );

  final Link link = authLink.concat(httpLink);

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(
        store: InMemoryStore(),
      ),
    ),
  );

  runApp(
    GraphQLProvider(
      client: client,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    AppConstants constants = AppConstants();

    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: constants.background,
      ),
    );

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      title: 'Unshooler AI',
      theme: ThemeData(
        scaffoldBackgroundColor: constants.background,
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        useMaterial3: true,
        splashFactory: InkRipple.splashFactory,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: constants.background,
          ),
          backgroundColor: constants.background,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const RouteManagerPage(),
        '/homePage': (context) => const HomePage(),
        '/settingsPage': (context) => const SettingsPage(),
        '/resultPage': (context) => const ResultPage(),
        '/authPage': (context) => const AuthPage(),
      },
    );
  }
}
