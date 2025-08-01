const mongoose = require('mongoose');

async function connectDB(fastify) {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    fastify && fastify.log ? fastify.log.info('MongoDB connected') : console.log('MongoDB connected');
  } catch (err) {
    if (fastify && fastify.log) {
      fastify.log.error('MongoDB connection error:', err.message);
    } else {
      console.error('MongoDB connection error:', err.message);
    }
    process.exit(1);
  }
}

module.exports = connectDB;