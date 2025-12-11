const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { check, validationResult } = require('express-validator');
const pool = require('../database/db');
const { sendEmail } = require('../utils/emailService');

// Register new user
router.post('/register', [
  check('id_number').notEmpty().withMessage('ID number is required'),
  check('email').isEmail().withMessage('Valid email is required'),
  check('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  check('name').notEmpty().withMessage('Name is required'),
  check('role').isIn(['student', 'coordinator', 'supervisor', 'admin']).withMessage('Invalid role')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id_number, email, password, name, department, role, phone } = req.body;

    // Check if user already exists
    const existingUser = await pool.query(
      'SELECT * FROM users WHERE email = $1 OR id_number = $2',
      [email, id_number]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const newUser = await pool.query(
      `INSERT INTO users (id_number, email, password, name, department, role, phone) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id, id_number, email, name, department, role`,
      [id_number, email, hashedPassword, name, department, role, phone]
    );

    res.status(201).json({
      message: 'User registered successfully',
      user: newUser.rows[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Login user
router.post('/login', [
  check('email').isEmail().withMessage('Valid email is required'),
  check('password').notEmpty().withMessage('Password is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password } = req.body;

    // Find user
    const user = await pool.query(
      'SELECT * FROM users WHERE email = $1 AND is_active = true',
      [email]
    );

    if (user.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check password
    const isValidPassword = await bcrypt.compare(password, user.rows[0].password);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Update last login
    await pool.query(
      'UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = $1',
      [user.rows[0].id]
    );

    // Generate tokens
    const accessToken = jwt.sign(
      { userId: user.rows[0].id, role: user.rows[0].role },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );

    const refreshToken = jwt.sign(
      { userId: user.rows[0].id },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );

    // Remove password from response
    const { password: _, ...userWithoutPassword } = user.rows[0];

    res.json({
      accessToken,
      refreshToken,
      user: userWithoutPassword
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Refresh token
router.post('/refresh-token', async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(401).json({ error: 'Refresh token required' });
    }

    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    const user = await pool.query(
      'SELECT id, role FROM users WHERE id = $1 AND is_active = true',
      [decoded.userId]
    );

    if (user.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    const newAccessToken = jwt.sign(
      { userId: user.rows[0].id, role: user.rows[0].role },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );

    res.json({ accessToken: newAccessToken });
  } catch (error) {
    console.error(error);
    res.status(401).json({ error: 'Invalid refresh token' });
  }
});

// Forgot password
router.post('/forgot-password', [
  check('email').isEmail().withMessage('Valid email is required')
], async (req, res) => {
  try {
    const { email } = req.body;
    
    const user = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    
    if (user.rows.length > 0) {
      // Generate reset token
      const resetToken = jwt.sign(
        { userId: user.rows[0].id },
        process.env.JWT_SECRET + user.rows[0].password,
        { expiresIn: '1h' }
      );

      // In production, send email with reset link
      const resetLink = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;
      
      // For development, return token
      if (process.env.NODE_ENV === 'development') {
        return res.json({ 
          message: 'Reset token generated (in production, email would be sent)',
          resetToken 
        });
      }

      // Production email sending
      await sendEmail({
        to: email,
        subject: 'Password Reset Request',
        html: `<p>Click <a href="${resetLink}">here</a> to reset your password.</p>`
      });
    }

    // Always return success to prevent email enumeration
    res.json({ message: 'If an account exists, a password reset email has been sent' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;