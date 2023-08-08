import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_strategy/url_strategy.dart';

import 'firebase_options.dart';

void main() async{
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getInitialMessage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String? mToken = '';
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();


  @override
  void initState() {
    super.initState();
    requestPermission();
    getToken();
    initInfo();
  }

  // initailize flutter local notification for androi and ios
  initInfo(){
    var androidInitialize = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize
    );

    flutterLocalNotificationsPlugin.initialize(initializationsSettings,onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{ 
      print("...............onMessage...........");
      print("onMessage: ${message.notification?.title}/${message.notification?.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContent: true
      );

      AndroidNotificationDetails androidNotificationDetails =  AndroidNotificationDetails(
          'flutter_fcm', 
          'flutter_fcm',
          importance: Importance.high,
          styleInformation: bigTextStyleInformation,
          priority: Priority.high,
        );
      
      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          threadIdentifier: 'flutter_fcm'
        )
      );

      await flutterLocalNotificationsPlugin.show(
        0, 
        message.notification?.title, 
        message.notification?.body, 
        notificationDetails,
        payload: message.data['body']
      );
    });
  }

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
}

// asked for permission for get notification from fcm
  void requestPermission() async{
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Permission granted: ${settings.authorizationStatus}');
    }
  }

// get token of particular device 
  void getToken() async{
    final messaging = FirebaseMessaging.instance;
    // TODO: replace with your own VAPID key
    const vapidKey = "BJIcGosKBefUsA2LzLeQEiOlsSlx-10EmKP0sTnpnDxR1imd-9QgjVecExFxtBZ8jOqiz6OyXffqI0p_mRuQoAc";

    // use the registration token to send messages to users from your trusted server environment
    String? token;
    // below if block is for get the token from web
    if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.web) {
      token = await messaging.getToken(
        vapidKey: vapidKey,
      );
    } 
    else {
      token = await messaging.getToken();
    }

    if(token != null){
      setState(() {
        mToken = token;
      });
      saveToken(token);
    };
    if (kDebugMode) {
      print('Registration Token=$token');
    }
  }

  // save the token of particular user in firebase firestore
  void saveToken(String token) async{

    await FirebaseFirestore.instance.collection("UserTokens").doc("User2").set({
      "token" : token,
    });
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: username,
            ),
            TextFormField(
              controller: title,
            ),
            TextFormField(
              controller: body,
            ),
            ElevatedButton(
              onPressed: (){
                String name = username.text.trim();
                String titleText = title.text;
                String bodyText = body.text;
              }, 
              child: const Text('Submit')
            )
          ],
        ),
      ) 
    );
  }
}
