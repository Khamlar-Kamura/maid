const jwt = require('jsonwebtoken');
const User = require('../models/User');

const authMiddleware = async (request, reply) => {
  let token;

  // ตรวจสอบ header Authorization
  if (
    request.headers.authorization &&
    request.headers.authorization.startsWith('Bearer')
  ) {
    try {
      token = request.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // decoded.id ต้องตรงกับที่ backend สร้าง token ตอน login
      request.user = await User.findById(decoded.id).select('-password');
      if (!request.user) {
        return reply.status(401).send({ message: 'Not authorized, user not found' });
      }
      // ผ่าน
      return;
    } catch (error) {
      console.error(error);
      return reply.status(401).send({ message: 'Not authorized, token failed' });
    }
  }

  // ถ้าไม่มี token
  return reply.status(401).send({ message: 'Not authorized, no token' });
};

module.exports = authMiddleware;