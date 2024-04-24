import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_setup/utils.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 22,
      color: Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: borderColor),
    ),
  );
  static const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
  static const fillColor = Color.fromRGBO(243, 246, 249, 0);
  static const borderColor = Color.fromRGBO(23, 171, 144, 0.4);
  late final arguments;


  @override
  Widget build(BuildContext context) {
    arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    debugPrint("argument data is: $arguments");
    return Scaffold(
      appBar: AppUtils.customAppbar(text: "Otp"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Pinput(
                length: 6,
                keyboardType: TextInputType.number,
                controller: pinController,
                defaultPinTheme: defaultPinTheme,
                onCompleted: (pin) {
                  debugPrint('onCompleted: $pin');
                },
                onChanged: (value) {
                  debugPrint('onChanged: $value');
                },
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: focusedBorderColor),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: focusedBorderColor),
                  ),
                ),
                errorPinTheme: defaultPinTheme.copyBorderWith(
                  border: Border.all(color: Colors.redAccent),
                ),
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                textInputAction: TextInputAction.next,
                showCursor: true,
                validator: (s) {
                  debugPrint('validating code: $s');
                },
              ),
              const SizedBox(height: 15.0),
              AppUtils.buildElevatedButton(() {
                validateOtp();
              }, "Submit"),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> validateOtp() async {
    focusNode.unfocus();
    formKey.currentState!.validate();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: arguments["verification_id"], smsCode: pinController.text);

      // Sign the user in (or link) with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(
          context, "/home_page", (route) => false);
    }on FirebaseAuth catch(e){
      debugPrint("error: ${e.toString()}");
    }


  }
}
