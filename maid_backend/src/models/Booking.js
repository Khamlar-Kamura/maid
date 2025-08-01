const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },

  service: String, // เช่น "ทำความสะอาด"
  residence: String, // ประเภทที่พัก
  bedrooms: Number,
  bathrooms: Number,
  otherRooms: [String],
  specialServices: [String],
  hours: Number,
  date: String, // หรือ Date ถ้าเก็บเป็นวันที่
  time: String, // หรือ Date/Time
  address: mongoose.Schema.Types.Mixed, // เก็บ object address ตามที่ Flutter ส่งมา
  price: Number,
  booking_date: { type: Date, default: Date.now }, // วันที่จอง
  status: { type: String, default: "pending" }, // สถานะการจอง
  // เพิ่ม field อื่นๆ ตามต้องการ
}, { timestamps: true });

module.exports = mongoose.model('Booking', bookingSchema);