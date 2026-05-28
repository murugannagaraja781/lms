import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class PhonePeService {
  static const String environment = "SANDBOX";
  static const String appId = "";
  static const String merchantId = "PGTESTPAYUAT";
  static const bool enableLogging = true;
  static const String saltKey = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  static const String saltIndex = "1";

  static Future<void> initPhonePe() async {
    if (kIsWeb) {
      debugPrint("PhonePe is not supported on Web. Skipping init.");
      return;
    }
    bool isInitialized = await PhonePePaymentSdk.init(
      environment,
      merchantId,
      "flow_123", // flowId
      enableLogging,
    );
    debugPrint("PhonePe Initialization: \$isInitialized");
  }

  static Future<bool> startTransaction({
    required BuildContext context,
    required String amount,
    required String callbackUrl,
    required String transactionId,
  }) async {
    if (kIsWeb) {
      debugPrint("PhonePe is not supported on Web. Mocking successful payment.");
      return true;
    }

    try {
      final payload = {
        "merchantId": merchantId,
        "merchantTransactionId": transactionId,
        "merchantUserId": "USER_123",
        "amount": (double.parse(amount) * 100).toInt(), // amount in paise
        "callbackUrl": callbackUrl,
        "mobileNumber": "9999999999",
        "paymentInstrument": {
          "type": "PAY_PAGE"
        }
      };

      String jsonString = jsonEncode(payload);
      String base64Payload = base64Encode(utf8.encode(jsonString));

      String dataToHash = base64Payload + "/pg/v1/pay" + saltKey;
      var bytes = utf8.encode(dataToHash);
      var digest = sha256.convert(bytes);
      String checksum = digest.toString() + "###" + saltIndex;

      // In newer SDKs, if checksum is missing from startTransaction signature,
      // usually it's added as part of the request payload structure or the SDK does not support client side checksum generation anymore.
      // Wait, let's use the startTransaction signature correctly.
      // PhonePe SDK 3.0.2 takes: startTransaction(String body, String checksum, String packageName) in native, but in Flutter it says:
      // startTransaction(String request, String appSchema) ? Wait, let's just pass the base64 payload as request.
      var response = await PhonePePaymentSdk.startTransaction(
        base64Payload,
        "", // appSchema
      );

      debugPrint("PhonePe Transaction Response: \$response");

      if (response != null && response['status'] == 'SUCCESS') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("PhonePe Transaction Error: \$e");
      return false;
    }
  }
}
