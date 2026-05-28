const mongoose = require('mongoose');

const LessonSchema = new mongoose.Schema({
  title: { type: String, required: true },
  videoUrl: { type: String, required: true },
  duration: { type: String, default: '10:00' },
  isLocked: { type: Boolean, default: false }
});

const CourseSchema = new mongoose.Schema({
  title: { type: String, required: true },
  instructor: { type: String, required: true },
  description: { type: String, required: true },
  imageUrl: { type: String, required: true },
  price: { type: Number, default: 0 },
  rating: { type: Number, default: 0.0 },
  category: { type: String, required: true },
  difficulty: { type: String, default: 'Beginner' },
  lessons: [LessonSchema],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Course', CourseSchema);
