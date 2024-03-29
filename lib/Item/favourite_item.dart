import 'package:app_thuong_mai/Item/detail_item.dart';
import 'package:flutter/material.dart';

class FavouriteItem extends StatelessWidget {
  final String path;
  final String name;
  final String origin;
  final String price;
  final bool status;
  final int token;
  final int userToken;
  const FavouriteItem({
    super.key, 
    required this.path, 
    required this.name, 
    required this.origin, 
    required this.price, 
    required this.status,
    required this.token,
    required this.userToken
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: Colors.grey)
      ),
      child: Column(
        children: [
          ListTile(
            leading: Image.network(path, width: 60, height: 60, fit: BoxFit.contain,),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
            subtitle: Text(origin),
            trailing: const Icon(Icons.arrow_forward_ios_outlined),
            onTap: (){
              try{
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailItem(idx: token, userToken: userToken)));
              }catch(e){
                print(e.toString());
              }
            },
          )
        ],
      ),
    );
  }
}