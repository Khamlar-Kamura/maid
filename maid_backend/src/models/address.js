// models/Address.js (ในฝั่ง Node.js)

const mongoose = require('mongoose');

const addressSchema = new mongoose.Schema({
  name: { type: String, required: true },
  placeName: { type: String, required: true },
  phone: { type: String, required: true },
  details: { type: String },
  note: { type: String },
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
  // อาจจะมี field อื่นๆ เช่น userId ที่เชื่อมกับผู้ใช้
  // userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' } 
}, { timestamps: true });

module.exports = mongoose.model('Address', addressSchema);