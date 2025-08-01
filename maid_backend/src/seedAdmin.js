require('dotenv').config();
const mongoose = require('mongoose');
const Admin = require('./models/Admin');
const bcrypt = require('bcrypt');

const MONGO_URI = process.env.MONGO_URI;

mongoose.connect(MONGO_URI);

async function createAdmin() {
  const username = 'admin'; // ชื่อแอดมิน
  const password = 'secret123'; // รหัสผ่านแอดมิน
  const hash = await bcrypt.hash(password, 10);

  const exists = await Admin.findOne({ username });
  if (exists) {
    console.log('Admin already exists');
    process.exit();
  }

  await Admin.create({ username, password: hash });
  console.log('Admin created');
  process.exit();
}

createAdmin();