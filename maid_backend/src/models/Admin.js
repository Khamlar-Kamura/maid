const mongoose = require('mongoose');

const adminSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  loginHistory: [Date], // ถ้าอยากเก็บประวัติ login
});

module.exports = mongoose.model('Admin', adminSchema);