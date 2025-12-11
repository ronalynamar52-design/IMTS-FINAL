# Internship Management & Tracking System (IMTS)

A complete production-ready internship management system with Flutter web frontend and Node.js/PostgreSQL backend.

## Features

### User Account Management
- Multi-role authentication (Student, Coordinator, Supervisor, Admin)
- Secure JWT-based authentication
- Password reset functionality

### Dashboard Overview
- Role-specific dashboards with widgets and charts
- Real-time notifications
- Activity summaries

### Internship Assignment
- Company management
- Student assignment to companies
- Task descriptions and deadlines

### Attendance and Daily Log
- Daily time tracking
- Supervisor verification
- Calendar view

### Progress Monitoring
- Periodic evaluations
- Performance metrics
- Progress reports

### Document Upload
- File upload system
- Validation status tracking
- Document management

### Messaging and Notifications
- Real-time messaging
- Announcement system
- WebSocket integration

### Report Generation
- PDF and Excel reports
- Attendance summaries
- Evaluation reports

### Checklist/Task Tracker
- Progress tracking
- Completion percentage
- Task verification

### Admin Control Panel
- User management
- System configuration
- Activity logs

## Tech Stack

### Frontend
- Flutter (Web + Mobile)
- Dart 3.0+
- Material Design 3

### Backend
- Node.js 18+
- Express.js
- PostgreSQL 15
- Socket.io for real-time communication

### Authentication
- JWT (Access + Refresh tokens)
- Role-based access control

### File Storage
- Local filesystem (with S3 compatibility)

### Reporting
- PDFKit for PDF generation
- ExcelJS for Excel reports

## Prerequisites

- Flutter SDK (3.0+)
- Node.js (18+)
- PostgreSQL (15+)
- Dart (3.0+)
- Git

## Quick Start with Docker

1. Clone the repository:
```bash
git clone https://github.com/yourusername/imts.git
cd imts