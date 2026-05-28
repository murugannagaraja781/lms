const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const serviceAccountPath = path.join(__dirname, '../serviceAccountKey.json');

if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('✅ Firebase Admin SDK Initialized');
} else {
  console.warn('⚠️ WARNING: serviceAccountKey.json not found! Firebase Auth verification will fail.');
}

const verifyToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized: No token provided' });
  }

  const token = authHeader.split(' ')[1];

  try {
    if (!admin.apps.length) {
      // If no admin SDK is set up, fallback for local dev (unsafe for prod)
      console.warn('Skipping verification because Firebase Admin is not configured.');
      req.user = { uid: 'test-user-uid', email: 'test@example.com' };
      return next();
    }

    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Error verifying token:', error);
    return res.status(403).json({ error: 'Unauthorized: Invalid token' });
  }
};

module.exports = verifyToken;
