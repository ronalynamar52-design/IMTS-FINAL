const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const dotenv = require('dotenv');
const { createServer } = require('http');
const { Server } = require('socket.io');
const path = require('path');

// Load environment variables
dotenv.config();

// Import routes
const authRoutes = require('./routes/auth');
const dashboardRoutes = require('./routes/dashboard');
// const userRoutes = require('./routes/users');
// const internshipRoutes = require('./routes/internships');
// const attendanceRoutes = require('./routes/attendance');
// const evaluationRoutes = require('./routes/evaluations');
// const documentRoutes = require('./routes/documents');
// const messageRoutes = require('./routes/messages');
// const reportRoutes = require('./routes/reports');
// const adminRoutes = require('./routes/admin');

// Import middleware
const { authenticateToken, checkRole } = require('./middleware/auth');
const { errorHandler } = require('./middleware/errorHandler');
const { logActivity } = require('./middleware/activityLogger');

// Initialize app
const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: process.env.FRONTEND_URL || "http://localhost:3000",
    credentials: true
  }
});

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || "http://localhost:3000",
  credentials: true
}));
app.use(limiter);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Activity logging middleware
app.use(logActivity);

// WebSocket connection handling
io.on('connection', (socket) => {
  console.log('New client connected');
  
  socket.on('join-room', (userId) => {
    socket.join(`user-${userId}`);
  });
  
  socket.on('send-message', (data) => {
    io.to(`user-${data.receiverId}`).emit('new-message', data);
  });
  
  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/dashboard', dashboardRoutes);
// app.use('/api/users', authenticateToken, userRoutes);
// app.use('/api/internships', authenticateToken, internshipRoutes);
// app.use('/api/attendance', authenticateToken, attendanceRoutes);
// app.use('/api/evaluations', authenticateToken, evaluationRoutes);
// app.use('/api/documents', authenticateToken, documentRoutes);
// app.use('/api/messages', authenticateToken, messageRoutes);
// app.use('/api/reports', authenticateToken, reportRoutes);
// app.use('/api/admin', authenticateToken, checkRole(['admin']), adminRoutes);

// Error handling middleware
app.use(errorHandler);

// Start server
const PORT = process.env.PORT || 5000;
httpServer.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = { app, io };
