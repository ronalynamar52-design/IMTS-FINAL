// backend/routes/attendance.js - COMPLETE EXAMPLE
const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const pool = require('../database/db');
const { authenticateToken, checkRole } = require('../middleware/auth');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, process.env.FILE_UPLOAD_PATH || './uploads');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, `attendance-${uniqueSuffix}${path.extname(file.originalname)}`);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5242880 },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|pdf|doc|docx/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only images and documents are allowed'));
    }
  }
});

// Submit daily log
router.post('/submit', 
  authenticateToken,
  checkRole(['student']),
  upload.single('attachment'),
  async (req, res) => {
    try {
      const { date, time_in, time_out, log_text } = req.body;
      const student_id = req.user.userId;
      
      // Calculate hours
      const timeIn = new Date(`2000-01-01T${time_in}`);
      const timeOut = new Date(`2000-01-01T${time_out}`);
      const hours = (timeOut - timeIn) / (1000 * 60 * 60);
      
      // Insert log
      const result = await pool.query(
        `INSERT INTO daily_logs 
         (student_id, date, time_in, time_out, hours, log_text, attachment_url) 
         VALUES ($1, $2, $3, $4, $5, $6, $7) 
         RETURNING *`,
        [student_id, date, time_in, time_out, hours, log_text, req.file?.filename]
      );
      
      // Send notification to supervisor
      const assignment = await pool.query(
        'SELECT supervisor_id FROM internship_assignments WHERE student_id = $1',
        [student_id]
      );
      
      if (assignment.rows[0]?.supervisor_id) {
        await pool.query(
          `INSERT INTO notifications (user_id, title, message, type) 
           VALUES ($1, 'New Attendance Log', 'Student submitted daily log', 'log')`,
          [assignment.rows[0].supervisor_id]
        );
        
        // Emit WebSocket event
        req.io.to(`user-${assignment.rows[0].supervisor_id}`)
          .emit('new-notification', {
            title: 'New Attendance Log',
            message: 'Student submitted daily log'
          });
      }
      
      res.status(201).json({
        message: 'Log submitted successfully',
        log: result.rows[0]
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// Get student's attendance
router.get('/student', authenticateToken, async (req, res) => {
  try {
    const { startDate, endDate, status } = req.query;
    const student_id = req.user.userId;
    
    let query = 'SELECT * FROM daily_logs WHERE student_id = $1';
    const params = [student_id];
    let paramCount = 2;
    
    if (startDate) {
      query += ` AND date >= $${paramCount}`;
      params.push(startDate);
      paramCount++;
    }
    
    if (endDate) {
      query += ` AND date <= $${paramCount}`;
      params.push(endDate);
      paramCount++;
    }
    
    if (status) {
      query += ` AND status = $${paramCount}`;
      params.push(status);
      paramCount++;
    }
    
    query += ' ORDER BY date DESC';
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;