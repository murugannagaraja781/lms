const express = require('express');
const router = express.Router();
const Course = require('../models/Course');
const verifyToken = require('../middleware/auth');

// Get all courses
router.get('/', verifyToken, async (req, res) => {
  try {
    const courses = await Course.find().sort({ createdAt: -1 });
    res.json(courses);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});

// Add a new course (Admin only conceptually, but checking token here)
router.post('/', verifyToken, async (req, res) => {
  try {
    const newCourse = new Course(req.body);
    await newCourse.save();
    res.json(newCourse);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});

// Delete a course
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    await Course.findByIdAndDelete(req.params.id);
    res.json({ message: 'Course deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});

module.exports = router;
