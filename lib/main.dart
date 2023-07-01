import 'dart:async';

import 'package:DFD/ui/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'ui/login_screen.dart';
import 'ui/no_internet_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ConnectivityResult _connectivityResult;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    _checkConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        if(result==ConnectivityResult.none){
          _isConnected=false;
        }

      });
    });
    super.initState();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      if(connectivityResult==ConnectivityResult.none){
        _isConnected=false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: _isConnected ? AppNavigator() : NoInternetScreen(),
    );
  }

}

class AppNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement your authentication logic to determine if the user is logged in
    bool isLoggedIn = false;
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      isLoggedIn=true;
    }
    return isLoggedIn ? MainScreen(user: user) : LoginScreen();
  }
}
