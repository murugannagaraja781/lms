const mongoose = require('mongoose');

const CommentSchema = new mongoose.Schema({
  lessonId: { type: String, required: true },
  courseId: { type: String, required: true },
  userId: { type: String, required: true },
  userName: { type: String, required: true },
  text: { type: String, required: true },
  replyText: { type: String, default: null },
  isReadByAdmin: { type: Boolean, default: false },
  timestamp: { type: Date, default: Date.now },
  replyTimestamp: { type: Date, default: null }
});

module.exports = mongoose.model('Comment', CommentSchema);
