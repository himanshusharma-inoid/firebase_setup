import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_setup/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppUtils {
  static AppBar customAppbar({String? text, String? imageUrl, VoidCallback? voidCallback, bool fromChatPage = false})
  {
    return AppBar(
      leadingWidth: 120,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if(voidCallback!= null)
            ...[InkWell(
                onTap: () {
                  voidCallback();
                },
                child: const Icon(Icons.arrow_back)),
            const SizedBox(width: 8.0)
          ],
            (imageUrl!= null) ? ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              child: CachedNetworkImage(
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.boy_outlined),
                imageUrl: imageUrl,
                height: 40.0,
                width: 40.0,
                fit: BoxFit.cover,
              ),
            ) : const SizedBox(),
        ]
        ),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (text!= null) ? Text(text) : const SizedBox(),
          if(fromChatPage == true)
            ValueListenableBuilder(
                valueListenable: typingStatus,
                builder: (BuildContext context, value, widget){
                  return Text((typingStatus.value == true) ? "typing" : "", style: const TextStyle(fontSize: 12));
                }),
        ],
      ),
      actions: [
        if(fromChatPage == true)
          ValueListenableBuilder(
              valueListenable: onlineStatus,
              builder: (BuildContext context, value, widget){
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text((onlineStatus.value == true) ? "online" : "offline", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                );
              }),

      ],
      centerTitle: true,
      backgroundColor: Colors.tealAccent,titleTextStyle:const TextStyle(color: Colors.deepPurple,fontSize: 30),);

  }
 static TextFormField  buildTextField({required TextEditingController controller, String? hint, Function(String?)? validate}){
   return TextFormField(
       controller: controller,
       validator: (values) => validate!(values),
       decoration: InputDecoration(
         hintText: (hint!=null) ? hint : null,
         border: OutlineInputBorder(
           borderRadius: BorderRadius.circular(16.0)
         )
       )
   );
 }

  static TextFormField  buildPhoneNumberTextFormField({required TextEditingController controller, String? hint, Function(String?)? callback, Function(String?)? validate}){
    return TextFormField(
        controller: controller,
        validator: (values) => validate!(values),
        decoration: InputDecoration(
           prefixIcon: CountryCodePicker(
            onChanged: (code){
              debugPrint("on changed ${code.name} ${code.dialCode}");
              if(callback != null)  callback(code.dialCode);
            },
            // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
            initialSelection: 'FR',
            // favorite: const ['+39', 'FR'],
            // countryFilter: const ['IT', 'FR'],
             showFlagMain: true,
             showFlag: true,
             showDropDownButton: false,
             flagWidth: 20,
            // comparator: (a, b) => b.name.compareTo(a.name),
            //Get the country information relevant to the initial selection
            onInit: (code) => debugPrint("on init ${code?.name} ${code?.dialCode}"),
          ),
            hintText: (hint!=null) ? hint : null,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0)
            )
        )
    );
  }

 static buildElevatedButton(VoidCallback voidCallback,String text){
    return SizedBox(height: 40,width: 200,child: ElevatedButton(onPressed: () => voidCallback(),
        child: Text(text)));
 }
 static customAlertBox(BuildContext context, {required String text}){
    return showDialog(context: context, builder:(BuildContext context){
      return AlertDialog(
         title: Text(text),
        );
    });
 }

  static loadingDialog(BuildContext context){
    return showDialog(context: context,
        barrierDismissible: false,
        builder:(BuildContext context){
      return  AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        title: const Row(
          children: [
            SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator()),
            SizedBox(width: 12.0),
            Text("Loading...")
          ],
        ),
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
       Text(text, style: TextStyle(color: (step == 2) ? Colors.deepPurple : Colors.grey, fontSize: 24, fontWeight: FontWeight.w400)),
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