import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class PhonePeService {
  static const String environment = "SANDBOX"; // Change to "PRODUCTION" when going live
  static const bool enableLogging = true;

  // IMPORTANT: The merchantId is now fetched from the backend dynamically
  static Future<void> initPhonePe(String merchantId) async {
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
    required String transactionId,
    required String token,
  }) async {
    if (kIsWeb) {
      debugPrint("PhonePe is not supported on Web. Mocking successful payment.");
      return true;
    }

    try {
      // 1. Fetch Secure Payload and Checksum from Node.js Backend
      final response = await http.post(
        Uri.parse('https://lms-bzuj.onrender.com/api/payments/initiate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \$token',
        },
        body: jsonEncode({
          'amount': amount,
          'transactionId': transactionId,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint("Failed to fetch payload from backend: \${response.body}");
        return false;
      }

      final data = jsonDecode(response.body);
      final base64Payload = data['base64Payload'];
      final checksum = data['checksum'];
      final merchantId = data['merchantId'];

      // 2. Initialize SDK with the exact merchantId from the backend
      await initPhonePe(merchantId);

      // 3. Start PhonePe SDK Transaction
      var sdkResponse = await PhonePePaymentSdk.startTransaction(
        base64Payload,
        "", // appSchema
      );

      debugPrint("PhonePe Transaction Response: \$sdkResponse");

      if (sdkResponse != null && sdkResponse['status'] == 'SUCCESS') {
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
