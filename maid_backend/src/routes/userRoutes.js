async function userRoutes(fastify, options) {
  const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');


  // ...existing code...

  // GET /api/users/me
  fastify.get('/me', { preHandler: authMiddleware }, async (request, reply) => {
  try {
    // ดึง user ใหม่จาก database เพื่อให้ได้ field ครบ
    const user = await User.findById(request.user.id);
    reply.send(user);
  } catch (err) {
    reply.status(500).send({ message: 'Server Error', error: err.message });
  }
});
  // ...existing code...

  // ดู user ทั้งหมด
  fastify.get('/', userController.getAllUsers);

  // เพิ่ม user ใหม่ (register)
  fastify.post('/', userController.createUser);

  // login
  fastify.post('/login', userController.login);

  // ดูข้อมูล user
  fastify.get('/:id', userController.getUserById);

  // แก้ไขข้อมูล user
  fastify.put('/:id', userController.updateUser);

  // ลบ user
  fastify.delete('/:id', userController.deleteUser);
}

module.exports = userRoutes;