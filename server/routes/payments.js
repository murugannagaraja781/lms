const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const verifyToken = require('../middleware/auth');

// Initialize a payment transaction
router.post('/initiate', verifyToken, async (req, res) => {
  try {
    const { amount, transactionId, mobileNumber } = req.body;
    
    // Read secure keys from .env
    const merchantId = process.env.PHONEPE_MERCHANT_ID;
    const saltKey = process.env.PHONEPE_SALT_KEY;
    const saltIndex = process.env.PHONEPE_SALT_INDEX || '1';

    if (!merchantId || !saltKey) {
      return res.status(500).json({ error: 'PhonePe credentials not configured on server' });
    }

    const payload = {
      merchantId: merchantId,
      merchantTransactionId: transactionId,
      merchantUserId: req.user.uid,
      amount: parseInt(amount) * 100, // PhonePe accepts amount in paise
      redirectUrl: "https://lms-bzuj.onrender.com/api/payments/callback",
      redirectMode: "POST",
      callbackUrl: "https://lms-bzuj.onrender.com/api/payments/callback",
      mobileNumber: mobileNumber || "9999999999",
      paymentInstrument: {
        type: "PAY_PAGE"
      }
    };

    // 1. Base64 Encode the JSON Payload
    const jsonString = JSON.stringify(payload);
    const base64Payload = Buffer.from(jsonString).toString('base64');

    // 2. Generate Checksum (SHA256(Base64Payload + apiEndPoint + saltKey) + ### + saltIndex)
    const apiEndPoint = "/pg/v1/pay";
    const stringToHash = base64Payload + apiEndPoint + saltKey;
    const checksum = crypto.createHash('sha256').update(stringToHash).digest('hex') + "###" + saltIndex;

    // Send back the secure payload to the Flutter App
    res.json({
      base64Payload: base64Payload,
      checksum: checksum,
      merchantId: merchantId
    });
  } catch (error) {
    console.error("Payment initiation error:", error);
    res.status(500).json({ error: 'Failed to initiate payment' });
  }
});

// Callback from PhonePe (Server-to-Server)
router.post('/callback', async (req, res) => {
  // In a full production app, you would verify the X-VERIFY header here using your salt key.
  // Then you would update the database transaction status.
  console.log("PhonePe Callback received:", req.body);
  res.status(200).send("OK");
});

module.exports = router;
