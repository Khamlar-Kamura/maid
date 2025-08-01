const Admin = require('../models/Admin');
const User = require('../models/User');
const bcrypt = require('bcrypt');

async function adminRoutes(fastify, options) {
  // แอดมินล็อกอิน
  fastify.post('/login', async (request, reply) => {
    const { username, password } = request.body;
    const admin = await Admin.findOne({ username });
    if (!admin) return reply.status(401).send({ message: 'Invalid credentials' });
    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) return reply.status(401).send({ message: 'Invalid credentials' });
    reply.send({ message: 'Login successful', admin: { username: admin.username } });
  });

  // ดูผู้ใช้ทั้งหมด
  fastify.get('/users', async (request, reply) => {
    const users = await User.find();
    reply.send(users);
  });

  // เพิ่มผู้ใช้ใหม่
  fastify.post('/users', async (request, reply) => {
    const { name, age, address, phone, email, password } = request.body;
    const hash = await bcrypt.hash(password, 10);
    const user = await User.create({ name, age, address, phone, email, password: hash });
    reply.send(user);
  });

  // แก้ไขผู้ใช้
  fastify.put('/users/:id', async (request, reply) => {
    const { name, age, address, phone, email } = request.body;
    const user = await User.findByIdAndUpdate(
      request.params.id,
      { name, age, address, phone, email },
      { new: true }
    );
    reply.send(user);
  });

  // ลบผู้ใช้
  fastify.delete('/users/:id', async (request, reply) => {
    await User.findByIdAndDelete(request.params.id);
    reply.send({ message: 'User deleted' });
  });
}

module.exports = adminRoutes;