const express = require('express');
const router = express.Router();
const User = require('../models/User');
const verifyToken = require('../middleware/auth');

// Sync User from Firebase to MongoDB
router.post('/sync', verifyToken, async (req, res) => {
  try {
    const { email, name, role } = req.body;
    const uid = req.user.uid;

    let user = await User.findOne({ uid });

    if (!user) {
      user = new User({
        uid,
        email: email || req.user.email,
        name: name || 'Student',
        role: role || 'student'
      });
      await user.save();
    } else if (role && user.role !== role) {
      user.role = role;
      await user.save();
    }

    res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});

// Admin Create User
router.post('/admin-create', verifyToken, async (req, res) => {
  try {
    // Only superadmin can create users this way
    const adminUser = await User.findOne({ uid: req.user.uid });
    if (!adminUser || adminUser.role !== 'superadmin') {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const { uid, email, name, role } = req.body;
    const user = new User({ uid, email, name, role });
    await user.save();
    
    res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});

// Get current user profile & progress
router.get('/me', verifyToken, async (req, res) => {
  try {
    const user = await User.findOne({ uid: req.user.uid });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});

// Get all users (SuperAdmin/Admin)
router.get('/', verifyToken, async (req, res) => {
  try {
    const adminUser = await User.findOne({ uid: req.user.uid });
    if (!adminUser || (adminUser.role !== 'admin' && adminUser.role !== 'superadmin')) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    const users = await User.find().sort({ _id: -1 });
    res.json(users);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});

// Enroll in a course
router.post('/enroll/:courseId', verifyToken, async (req, res) => {
  try {
    const user = await User.findOne({ uid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const courseId = req.params.courseId;
    if (!user.enrolledCourses) user.enrolledCourses = new Map();
    
    if (!user.enrolledCourses.has(courseId)) {
      user.enrolledCourses.set(courseId, { completedLessons: [] });
      await user.save();
    }

    res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});

// Complete a lesson
router.post('/complete/:courseId/:lessonId', verifyToken, async (req, res) => {
  try {
    const user = await User.findOne({ uid: req.user.uid });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const { courseId, lessonId } = req.params;
    
    if (user.enrolledCourses && user.enrolledCourses.has(courseId)) {
      const courseProgress = user.enrolledCourses.get(courseId);
      if (!courseProgress.completedLessons.includes(lessonId)) {
        courseProgress.completedLessons.push(lessonId);
        user.enrolledCourses.set(courseId, courseProgress);
        await user.save();
      }
    }

    res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});

module.exports = router;
