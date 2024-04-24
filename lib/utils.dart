import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppUtils {
  static AppBar customAppbar({String? text})
  {
    return AppBar(
      title: (text!= null) ? Text(text) : null,
      backgroundColor: Colors.deepPurple,titleTextStyle:const TextStyle(color: Colors.white,fontSize: 30),);

  }
 static TextField  buildTextField({required TextEditingController controller, String? hint}){
   return TextField(
       controller: controller,
       decoration: InputDecoration(
         hintText: (hint!=null) ? hint : null,
         border: OutlineInputBorder(
           borderRadius: BorderRadius.circular(16.0)
         )
       )
   );
 }

 static buildElevatedButton(VoidCallback voidCallback,String text){
    return SizedBox(height: 40,width: 200,child: ElevatedButton(onPressed: () =>voidCallback(),
        child: Text(text)));
 }
 static customAlertBox(BuildContext context, {required String text}){
    return showDialog(context: context, builder:(BuildContext context){
      return AlertDialog(
         title: Text(text),
        );
    });
 }
static void showToast({String? message}) {
  Fluttertoast.showToast(msg: message.toString());
}

static Text commonText(String text){
    return Text(text, style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w700));
}

static Widget buildEmailTabWidget(BuildContext context, String text, VoidCallback voidCallback, int step){
 return InkWell(
   onTap: () => voidCallback(),
   child: Column(
     children: [
       Text(text, style: TextStyle(color: (step == 1) ? Colors.deepPurple : Colors.grey, fontSize: 24, fontWeight: FontWeight.bold),),
       Container(
           width: MediaQuery.of(context).size.width * 0.2,
           height: 3,
           decoration: BoxDecoration(
             color: (step == 1) ? Colors.deepPurple : Colors.grey,
               borderRadius: BorderRadius.circular(12.0)
           )),
     ],
   ),
 );
}
static Widget buildPhoneTabWidget(BuildContext context, String text, VoidCallback voidCallback, int step){
 return InkWell(
   onTap: () => voidCallback(),
   child: Column(
     children: [
       Text(text, style: TextStyle(color: (step == 2) ? Colors.deepPurple : Colors.grey, fontSize: 24, fontWeight: FontWeight.w400),),
       Container(
           width: MediaQuery.of(context).size.width * 0.2,
           height: 3,
           decoration: BoxDecoration(
             color: (step == 2) ? Colors.deepPurple : Colors.grey,
               borderRadius: BorderRadius.circular(12.0)
           )),
     ],
   ),
 );
}

}