async function authRoutes(fastify, options) {
  const authController = require('../controllers/authController');

  fastify.post('/send-otp', authController.sendOtp);
  fastify.post('/register-with-otp', authController.registerWithOtp);
  fastify.post('/login', authController.login);
}

module.exports = authRoutes;