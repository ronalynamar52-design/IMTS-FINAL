const errorHandler = (err, req, res, next) => {
  console.error(err.stack);

  res.status(500).json({
    error: 'Something went wrong!',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
  });
};

module.exports = { errorHandler };
