import 'package:app_thuong_mai/Item/cart_item.dart';
import 'package:app_thuong_mai/navigate/bot_nav.dart';
import 'package:app_thuong_mai/screen/order_pay.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final int userToken;
  const CartScreen({super.key, required this.userToken});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase(
    databaseURL:
        'https://app-thuong-mai-ndtt-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).reference();

  bool ischeck = false;
  
  //Danh sách người dùng
  List<Map<dynamic, dynamic>> user = [];

  //Danh sách giỏ hàng
  List<dynamic> lst_cat = [];

  //Danh sách lưu trữ thanh toán
  List<Map<dynamic, dynamic>> lst_pay = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _resetFormData();
  }

  Future<void> _fetchData() async {
    try {
      DatabaseEvent event = await _databaseReference.once();
      DataSnapshot? dataSnapshot = event.snapshot;

      if (dataSnapshot != null && dataSnapshot.value != null) {
        List<dynamic> data = (dataSnapshot.value as Map)['users'];
        data.forEach((value) {
          user.add(value);
        });
        for(var value in user[widget.userToken]['cats']){
          lst_cat.add(value);
        }
        print(lst_cat);
        print(lst_cat.length);
        setState(() {});
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void checkStatus() async {
    try {
      for(int i = 0; i < lst_cat.length; i++){
        if(lst_cat[i]['status'] == true){
          ischeck = true;
          lst_pay.add(lst_cat[i]);
        }
      }
    }
    catch(e){
      print(e.toString());
    }
  }
  void _resetFormData() async {
    _databaseReference.child('users/${widget.userToken}').child('cats').onValue.listen((event) {
      _handleDataChange(event.snapshot);
    });
  }

  void _handleDataChange(DataSnapshot snapshot) {
    try {
      if (snapshot != null && snapshot.value != null) {
        //resetScreen();
      }
    } catch (error) {
      print("Error handling data change: $error");
    }
  }

  void resetScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CartScreen(userToken: widget.userToken)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 8.0,),
            const Text(
              'Giỏ hàng',
              style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1), fontSize: 30),
            ),
            Expanded(
              child: SizedBox(
                height: 144.0, 
                child: 
                ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: lst_cat.length,
                  itemBuilder: (context, index) {
                    try{
                      if(user[widget.userToken]['cats'][index]['status'])
                      {
                        return CartItem(
                          path: user[widget.userToken]['cats'][index]['path']??'',
                          name: user[widget.userToken]['cats'][index]['name']??'',
                          price: user[widget.userToken]['cats'][index]['price']??'',
                          origin: user[widget.userToken]['cats'][index]['origin']??'',
                          quantity: user[widget.userToken]['cats'][index]['quantity'],
                          status: user[widget.userToken]['cats'][index]['status'],
                          userToken: widget.userToken,
                          idx: user[widget.userToken]['cats'][index]['cat_token'],
                        );
                      }
                      else
                      { 
                        return const SizedBox();
                      }
                    }
                    catch(e)
                    {
                      e.toString();
                    }
                  },
                )
              ),
            ),

            Container(
              height: 50.0,
              width: 150.0,
              child: Center(
                child: ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Color.fromRGBO(87, 175, 115, 1)
                    )
                  ),
                  onPressed: (){
                    checkStatus();
                    Navigator.push(context, MaterialPageRoute(builder: ((context) => OrderPay(userToken: widget.userToken))));
                  }, 
                  child: const Text(
                    'Thanh Toán',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0
                    ),
                  )
                ),
              ),
            )
          ],
        ) 
      ),
      bottomNavigationBar: BotNav(idx: 1, userToken: widget.userToken,),
    );
  }
}