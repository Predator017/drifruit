import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'myaccount_screen.dart';

class MainScreen extends StatefulWidget {
  final User? user;

  MainScreen({required this.user});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late ProgressDialog _progressDialog;
  List<Widget>? _screens;
  final List<Widget> _cachedScreens = [];
  bool dataloaded=false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    _screens=[
      HomeScreen(user: widget.user, iscached: false,showProgressDialog: showProgressDialog, hideProgressDialog: hideProgressDialog),
      CategoriesScreen(),
      CartScreen(),
      MyAccountScreen(),
    ];
    _cacheScreens();
    _progressDialog = ProgressDialog(context,isDismissible: false);
    _progressDialog.style(

      message: "Loading...",

      progressWidget: Container(

          padding: EdgeInsets.all(18.0), child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
      )),
      maxProgress: 100.0,

      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),

    );


  }

  void _loadData() async {
    // Simulating data loading
    await Future.delayed(Duration(seconds: 2));
    dataloaded=true;
    // Set the flag to indicate data loaded

  }







  void showProgressDialog() {
    _progressDialog.show();
  }
  void hideProgressDialog() {
    _progressDialog.hide();
  }
  void _cacheScreens() {
    for (int i = 0; i < _screens!.length; i++) {
      if (_screens![i] is HomeScreen) {
        _cachedScreens.add(HomeScreen(user: widget.user,iscached: true,showProgressDialog: showProgressDialog, hideProgressDialog: hideProgressDialog));
      } else {
        _cachedScreens.add(_screens![i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!dataloaded) {
      return Scaffold(
        body: _screens?[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.brown,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.transparent,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
      );
    }
    else{
      return Scaffold(
        body: _cachedScreens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.brown,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.transparent,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
      );
    }

  }
}
