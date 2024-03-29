import 'dart:math';
import 'package:app_thuong_mai/Item/notification_item.dart';
import 'package:app_thuong_mai/main.dart';
import 'package:app_thuong_mai/navigate/bot_nav.dart';
import 'package:app_thuong_mai/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  final int userToken;
  const NotificationScreen({super.key,required this.userToken});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  TextEditingController status = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference = FirebaseDatabase(
    databaseURL:
        'https://app-thuong-mai-ndtt-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).reference();
  int notiCount = 0;
  List<Map<dynamic, dynamic>> user_cat = [];
  List<dynamic?> lst_notification = [];

  Future<void> _fetchData() async {
    try {
      DatabaseEvent event = await _databaseReference.once();
      DataSnapshot? dataSnapshot = event.snapshot;

      if (dataSnapshot != null && dataSnapshot.value != null) {
        List<dynamic> data = (dataSnapshot.value as Map)['users'];
        data.forEach((value) {
          user_cat.add(value);
        });
        try {
          for (var value in user_cat[widget.userToken]['notifications']) {
            lst_notification.add(value);
          }
        } catch (e) {
          print('error' + e.toString());
        }
        setState(() {});
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void editUser(int index) async {
    try {
      await _databaseReference.child('users/${widget.userToken}').child('notifications/${index}').update({
        'status': false,
      });
    } catch (error) {
      print(error.toString());
    }
  }

  String titleOrder = '';

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem tất cả các thông báo có trạng thái là false không
    bool allNotificationsFalse = user_cat.isNotEmpty &&
    user_cat[widget.userToken]['notifications'] != null &&
    user_cat[widget.userToken]['notifications'].every((notification) => notification['status'] == false);
    bool ktra=false;
    print('Giá trị của allNotificationsFalse là: $allNotificationsFalse');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          leading:null,
        title: Text('Thông báo', style: TextStyle(color: Colors.black),),
      ),
      body: allNotificationsFalse
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications, size: 50, color: Colors.yellow),
                  SizedBox(height: 30,),
                  Text('Không có thông báo', style: TextStyle(color: Colors.green, fontSize: 20)),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(userToken: widget.userToken,)));
                    },
                    child: Text('Quay về Trang Chủ'),
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: lst_notification.length,
              itemBuilder: (context, index) {
                try {
                  var item = lst_notification[index];
                  if (user_cat[widget.userToken]['notifications'][index]['status'] == true) {
                    titleOrder = '${user_cat[widget.userToken]['notifications'][index]['title']}';
                    return Dismissible(
                      key: Key(item.toString()),
                      onDismissed: (direction) {
                        setState(() {
                          lst_notification.removeAt(index);
                          editUser(index);
                          print(lst_notification);
                          item.removeAt(index);
                          ktra = user_cat.isNotEmpty &&
                              user_cat[widget.userToken]['notifications'].every((notification) => notification['status'] == false);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đơn hàng đã được xóa')),
                        );
                      },
                      background: Container(color: Colors.red),
                      child: NotificationItem(userToken: widget.userToken,title: titleOrder),
                    );
                  } else {
                    return Container(); // Không hiển thị thông báo có trạng thái false
                  }
                } catch (error) {
                  print("Lỗi khi xử lý thay đổi dữ liệu: $error");
                  return Container(); // Xử lý lỗi bằng cách trả về một container trống hoặc một widget thay thế
                }
              },
            ),
            bottomNavigationBar: BotNav(idx: 2, userToken: widget.userToken,),
    );
  }
}