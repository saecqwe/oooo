import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:kappu/common/bottom_nav_bar.dart';
import 'package:kappu/constants/storage_manager.dart';
import 'package:kappu/provider/provider_provider.dart';
import 'package:kappu/provider/userprovider.dart';
import 'package:kappu/screens/login/login_screen.dart';
import 'package:kappu/screens/login/splash_view.dart';
import 'package:kappu/screens/login_registration.dart/login_registration.dart';
import 'package:provider/provider.dart';
import 'components/AppColors.dart';
import 'main_context.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageManager().init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  // await messaging.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  // Stripe.publishableKey = "pk_test_51Lde8bIv5chsib1Pz9bXZPJbZcDZnozh8J4k0w13wI9UyvA9Oh5E7mRRm2uNatxGhIegAWpIWG08rRYJOrO6s68q00lYAdkoY6";
  Stripe.publishableKey = "pk_live_51Lde8bIv5chsib1PXmka1VnQgYqfn3uSUcUXqpN0OF1pF2h4qnp5LWhmt5ZUrKWTtcOQ2sqCPDuoWIB73nu3X9Ji005rPDnoEU";
  runApp(Phoenix(child: MyApp(messaging: messaging)));
}

class MyApp extends StatefulWidget {
  final FirebaseMessaging messaging;

  const MyApp({Key? key, required this.messaging}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<String> _base64encodedImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    final String base64Data = base64Encode(response.bodyBytes);
    return base64Data;
  }

  String largeIconPath = '';

  @override
  void initState() {
    super.initState();
    var initialzationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingios = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initialzationSettingsAndroid, iOS: initializationSettingios);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("hello");
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      print("hello");
      if (notification != null && android != null) {
        print("showing notification");
        final String largeIcon =
            await _base64encodedImage(message.notification!.android!.imageUrl!);
        final String bigPicture =
            await _base64encodedImage(message.notification!.android!.imageUrl!);
        final BigPictureStyleInformation bigPictureStyleInformation =
            BigPictureStyleInformation(
                ByteArrayAndroidBitmap.fromBase64String(
                    bigPicture), //Base64AndroidBitmap(bigPicture),
                largeIcon: ByteArrayAndroidBitmap.fromBase64String(largeIcon),
                contentTitle: '<b>${message.notification!.title}</b>',
                htmlFormatContentTitle: true,
                summaryText: message.notification!.body,
                htmlFormatSummaryText: true);

        final AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
                'big text channel id', 'big text channel name',
                channelDescription: 'big text channel description',
                styleInformation: bigPictureStyleInformation);
        final NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            0,
            message.notification!.title,
            message.notification!.body,
            platformChannelSpecifics);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(">>>>>>>>>>>>>");
      print(message.data);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });

    getToken();
  }

  String token = '';


  getToken() async {
    token = (await widget.messaging.getToken())!;
    StorageManager().fcmToken =token;
    print("!!!!!!!!!!!!!!!");
    print(token);
  }

  // GoogleSignInAccount? _currentuser;

  // @override
  // void initState() {
  //   _googleSignIn.onCurrentUserChanged.listen(
  //     (account) {
  //       setState(() {
  //         _currentuser = account;
  //       });
  //     },
  //   );
  //   _googleSignIn.signInSilently();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // GoogleSignInAccount? user = _currentuser;

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => ProviderProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => UserProvider(),
            ),

          ],
          child: MaterialApp(
              navigatorKey: NavigationService.navigatorKey,
              title: 'UrbanMalta',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                scaffoldBackgroundColor: Colors.white,
              ),
              home: const InitialScreen())),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: StorageManager().accessToken.isNotEmpty
            ? BottomNavBar(
                isprovider: StorageManager().isProvider,
              )
            : const SplashView());
  }
}
//flutter clean
//flutter packages get
//flutter downgrade
//flutter run