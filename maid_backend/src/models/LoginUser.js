const mongoose = require('mongoose');

const loginUserSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String }, // เพิ่มบรรทัดนี้
  loginAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('LoginUser', loginUserSchema);