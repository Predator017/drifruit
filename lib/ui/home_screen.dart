import 'package:shared_preferences/shared_preferences.dart';

import 'item_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'login_screen.dart';


class HomeScreen extends StatefulWidget {
  final User? user;
  final bool iscached;
  final Function showProgressDialog;
  final Function hideProgressDialog;

  HomeScreen(
      {
        required this.user,
        required this.iscached,
        required this.showProgressDialog,
        required this.hideProgressDialog,
      });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  String? _previousLocation;
  List<Widget>? _screens;
  int _currentIndex = 0;
  final List<Widget> _cachedScreens = [];
  late ProgressDialog _progressDialog;
  bool _dataLoaded = false;
  String _searchQuery = '';

  List<Item> _items = [];
  late List<AppBar> _appBars;
  final List<Item> _filteredItems = [];
  String _currentLocation='';
  late SharedPreferences _preferences;

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      if(!widget.iscached){
        _checkLocationPermission();
      }
      else{
        _getCurrentLocationFromCache();
      }




      _loadProducts();

    });
  }

  void _getCurrentLocationFromCache() {
    SharedPreferences.getInstance().then((cache) {
      final savedLocation = cache.getString('currentLocation');
      setState(() {
        _currentLocation = savedLocation ?? '';
      });
    });
  }



  Future<void> _checkLocationPermission() async {

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await _getCurrentLocation();
    } else {
      // Handle the case when the user denied the location permission
      print('Location permission denied');
    }

  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String name = placemark.name ?? '';
        String thoroughfare = placemark.thoroughfare ?? '';
        String sublocality = placemark.subLocality ?? '';
        String locality = placemark.locality ?? '';
        String administrativeArea = placemark.administrativeArea ?? '';
        String postalCode = placemark.postalCode ?? '';

          setState(() {
            _currentLocation =
            '$name, $thoroughfare, $sublocality, $locality, $administrativeArea, $postalCode';
          });

          if(!widget.iscached){
            _updateLocationInCache(_currentLocation);
          }

      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateLocationInCache(String location) async {
    final cache = await SharedPreferences.getInstance();
    await cache.setString('currentLocation', location);
    setState(() {
      _previousLocation = location;
    });
  }

  Future<void> _loadProducts() async{

    if(!widget.iscached) {
      widget.showProgressDialog();
    }


    DatabaseReference reference = FirebaseDatabase.instance.reference().child('Products');
    reference.onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot != null && snapshot.value != null) {
        fetchData(snapshot);
      }
    });
  }

  Future<void> fetchData(DataSnapshot snapshot) async {
    List<Item> items = [];

    Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
    value.forEach((key, data) {
      Map<dynamic, dynamic> singleUser = data as Map<dynamic, dynamic>;

      // Access the required fields and add them to the respective lists
      String imageUrl = singleUser['image'].toString();
      String itemName = singleUser['itemname'].toString();
      String originalPrice = singleUser['originalprice'].toString();
      String discount = singleUser['discount'].toString();
      double discountPrice = double.parse(originalPrice)-((int.parse(originalPrice)*int.parse(discount))/100);
      //print(imageUrl + " " + itemName + " " + originalPrice);
      items.add(Item(itemName, imageUrl, int.parse(originalPrice),discountPrice.toInt(),int.parse(discount)));
    });

    setState(() {
      _items = items;
      _filteredItems.addAll(_items);
        Future.delayed(Duration(seconds: 5), () {
          widget.hideProgressDialog();
          //_progressDialog.hide();
        });



    });
  }






  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      _filteredItems.clear();
      if (query.isNotEmpty) {
        _filteredItems.addAll(
          _items.where((item) =>
              item.name.toLowerCase().contains(query.toLowerCase())),
        );
      } else {
        _filteredItems.addAll(_items);

      }
    });
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.brown,
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                !_currentLocation.isEmpty ? _currentLocation : 'Loading...',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterItems(value);
              },
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey),
                // Color for the hint text
                prefixIcon: Icon(Icons.search, color: Colors.brown),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.brown, // Set the highlight color to brown
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.brown, width: 2.0),
                ),
                labelStyle: TextStyle(color: Colors.brown),
                contentPadding: EdgeInsets.symmetric(vertical: 7),
              ),

              // Add this line to set the text value
              cursorColor: Colors.brown, // Set the cursor color to brown
              textAlign: TextAlign.start, // Set the cursor position to start
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(8),
              children: _filteredItems
                  .map((item) => _buildItemCard(item, context))
                  .toList(),
            ),
          ),
        ],
      ),



    );

  }
}





Widget _buildItemCard(Item item,BuildContext context) {

  return GestureDetector(
      onTap: () {
        // Navigate to the item page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemPage(item:item,),
          ),
        );
      },
      child: Card(

        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child:Center(
                  child: Image.network(
                    item.imageURL, // Replace item.imagePath with the HTTPS link to your image
                    fit: BoxFit.fill  ,
                    alignment: Alignment.center,



                  ),

                ),
              ),

            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(fontSize: 14,color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                    Text(
                      ' ₹${item.originalprice} ',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      ' ₹${item.discountprice} ',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' ${item.discount}% OFF ',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                      ),
                    ),
                  ],
                  )
                  ,

                ],
              ),
            ),
          ],
        ),
      )
  );

}


class Item {
  final String name;
  final String imageURL;
  final int originalprice;
  final int discountprice;
  final int discount;


  Item(this.name, this.imageURL, this.originalprice,this.discountprice,this.discount);
}