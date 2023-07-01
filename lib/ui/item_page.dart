import 'home_screen.dart';
import 'package:flutter/material.dart';

class ItemPage extends StatefulWidget {
  final Item item;

  ItemPage({required this.item});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  int itemCount = 1;

  void incrementItemCount() {
    setState(() {
      itemCount++;
    });
  }

  void decrementItemCount() {
    setState(() {
      if (itemCount > 1) {
        itemCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Order Details',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(1),
            child: Image.network(
              widget.item.imageURL,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              widget.item.name,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(top: 50,left: 50),
              child: Text(
                '₹${widget.item.discountprice}',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container
            (
            margin:EdgeInsets.only(top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(

                  icon: Icon(Icons.remove),
                  onPressed: decrementItemCount,
                ),
                SizedBox(width: 10),
                Text(
                  itemCount.toString(),
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: incrementItemCount,
                ),
              ],
            ),
          ),

        ],
      ),
      floatingActionButton: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Add to cart logic
            print('Item Count: $itemCount'); // Example of using the itemCount value
          },
          label: Text('Add to Cart'),
          backgroundColor: Colors.brown,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
