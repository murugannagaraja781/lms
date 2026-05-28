const express = require('express');
const router = express.Router();
const Comment = require('../models/Comment');
const verifyToken = require('../middleware/auth');

// Get all comments
router.get('/', verifyToken, async (req, res) => {
  try {
    const comments = await Comment.find().sort({ timestamp: -1 });
    res.json(comments);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});

// Post a new comment
router.post('/', verifyToken, async (req, res) => {
  try {
    const newComment = new Comment({
      ...req.body,
      userId: req.user.uid,
      userName: req.body.userName || 'Student'
    });
    await newComment.save();
    res.json(newComment);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});

// Reply to a comment (Admin)
router.post('/reply/:id', verifyToken, async (req, res) => {
  try {
    const { replyText } = req.body;
    const comment = await Comment.findById(req.params.id);
    if (!comment) return res.status(404).json({ error: 'Comment not found' });

    comment.replyText = replyText;
    comment.replyTimestamp = new Date();
    comment.isReadByAdmin = true;
    
    await comment.save();
    res.json(comment);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});

module.exports = router;
