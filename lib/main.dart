import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/check_network/network_binding.dart';
import 'package:lets_adventure/locale/locale.dart';
import 'package:lets_adventure/locale/locale_controller.dart';
import 'package:lets_adventure/screens/splash/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'firebase_options.dart';

SharedPreferences? sharepref1;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  sharepref1 = await SharedPreferences.getInstance();
  if (defaultTargetPlatform == TargetPlatform.android) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    MyLocaleController controller = Get.put(MyLocaleController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: controller.initialLang,
      translations: MyLocale(),
      initialBinding: NetworkBinding(),
      home: SplashScreen(),
    );
  }
}
