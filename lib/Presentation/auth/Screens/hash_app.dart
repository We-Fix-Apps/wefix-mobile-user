import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class GetAppSignatureScreen extends StatefulWidget {
  const GetAppSignatureScreen({super.key});

  @override
  State<GetAppSignatureScreen> createState() => _GetAppSignatureScreenState();
}

class _GetAppSignatureScreenState extends State<GetAppSignatureScreen> {
  String? appSignature;

  @override
  void initState() {
    super.initState();
    _getSignature();
  }

  Future<void> _getSignature() async {
    String signature = await SmsAutoFill().getAppSignature;
    setState(() {
      appSignature = signature;
    });
    debugPrint("📌 App Signature: $signature");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Signature Hash")),
      body: Center(
        child: Text(
          appSignature ?? "Fetching...",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
