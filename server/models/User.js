const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  uid: { type: String, required: true, unique: true }, // Firebase UID
  email: { type: String, required: true },
  name: { type: String, required: true },
  role: { type: String, default: 'student', enum: ['student', 'admin', 'superadmin'] },
  enrolledCourses: {
    type: Map,
    of: {
      completedLessons: [String]
    },
    default: {}
  },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', UserSchema);
