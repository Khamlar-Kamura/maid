const User = require('../models/User');
const bcrypt = require('bcrypt');

// login
exports.login = async (request, reply) => {
  try {
    const { email, name, password } = request.body;
    // หา user จาก email หรือ name
    const user = email
      ? await User.findOne({ email: email.trim() })
      : await User.findOne({ name: name });

    if (!user) {
      return reply.status(400).send({ message: 'ບໍ່ພົບຜູ້ໃຊ້' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return reply.status(400).send({ message: 'ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ' });
    }

    // ไม่ส่ง password กลับ
    const { password: pw, ...userSafe } = user.toObject();
    reply.send({ message: 'ເຂົ້າສູ່ລະບົບສຳເລັດ', user: userSafe });
  } catch (err) {
    reply.status(500).send({ error: err.message });
  }
};

// ดู user ทั้งหมด
exports.getAllUsers = async (request, reply) => {
  try {
    const users = await User.find().select('-password');
    reply.send(users);
  } catch (err) {
    reply.status(500).send({ error: err.message });
  }
};

// เพิ่ม user ใหม่
exports.createUser = async (request, reply) => {
  try {
    const { name, age, address, phone, email, password } = request.body;
    if (!email || !password) {
      return reply.status(400).send({ message: 'Email and password are required' });
    }
    const exist = await User.findOne({ email: email.trim() });
    if (exist) return reply.status(400).send({ message: 'Email already exists' });

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({ name, age, address, phone, email: email.trim(), password: hashedPassword });
    await user.save();
    const { password: pw, ...userSafe } = user.toObject();
    reply.status(201).send({ message: 'User created', user: userSafe });
  } catch (err) {
    reply.status(500).send({ error: err.message });
  }
};

// ดูข้อมูล user
exports.getUserById = async (request, reply) => {
  try {
    const user = await User.findById(request.params.id).select('-password');
    if (!user) return reply.status(404).send({ message: 'User not found' });
    reply.send(user);
  } catch (err) {
    reply.status(500).send({ error: err.message });
  }
};

// แก้ไขข้อมูล user
exports.updateUser = async (request, reply) => {
  try {
    const { name, age, address, phone, email } = request.body;
    const user = await User.findByIdAndUpdate(
      request.params.id,
      { name, age, address, phone, email },
      { new: true }
    ).select('-password');
    if (!user) return reply.status(404).send({ message: 'User not found' });
    reply.send({ message: 'User updated', user });
  } catch (err) {
    reply.status(500).send({ error: err.message });
  }
};

// ลบ user
exports.deleteUser = async (request, reply) => {
  try {
    const user = await User.findByIdAndDelete(request.params.id);
    if (!user) return reply.status(404).send({ message: 'User not found' });
    reply.send({ message: 'User deleted' });
  } catch (err) {
    reply.status(500).send({ error: err.message });
  }
};