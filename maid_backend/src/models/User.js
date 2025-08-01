const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  age: Number,
  village: String,    // บ้าน
  city: String,       // เมือง
  province: String,   // แขวง
  phone: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  profile_image: {
    type: String,
    default: null 
  }
});

module.exports = mongoose.model('User', userSchema);