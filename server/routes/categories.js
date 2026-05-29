const express = require('express');
const router = express.Router();
const Category = require('../models/Category');
const verifyToken = require('../middleware/auth');

// Get all categories
router.get('/', async (req, res) => {
  try {
    const categories = await Category.find().sort({ createdAt: 1 });
    res.json(categories);
  } catch (err) {
    res.status(500).json({ error: 'Server error fetching categories' });
  }
});

// Add a new category (Requires Super Admin logic, assuming verifyToken sets req.user and we handle role based logic client-side or verify it here)
router.post('/', verifyToken, async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) return res.status(400).json({ error: 'Category name is required' });

    const newCategory = new Category({ name });
    await newCategory.save();
    res.status(201).json(newCategory);
  } catch (err) {
    if (err.code === 11000) {
      return res.status(400).json({ error: 'Category already exists' });
    }
    res.status(500).json({ error: 'Server error adding category' });
  }
});

// Delete a category
router.delete('/:name', verifyToken, async (req, res) => {
  try {
    const name = req.params.name;
    const deletedCategory = await Category.findOneAndDelete({ name: name });
    if (!deletedCategory) {
      return res.status(404).json({ error: 'Category not found' });
    }
    res.json({ message: 'Category deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Server error deleting category' });
  }
});

module.exports = router;
