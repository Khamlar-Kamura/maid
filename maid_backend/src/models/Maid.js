const mongoose = require('mongoose');

const maidSchema = new mongoose.Schema({
  maid_id: { type: String, unique: true, required: true },
  full_name: { type: String, required: true },
  phone_number: { type: String, required: true },
  email: { type: String },
  address: { type: String },
  location: {
    lat: { type: Number },
    lng: { type: Number }
  },
  gender: { type: String, enum: ['หญิง', 'ชาย', 'อื่นๆ'] },
  age: { type: Number },
  skills: { type: [String], default: [] },
  experience_years: { type: Number, default: 0 },
  preferred_work_type: { type: [String], default: [] },
  available_days: { type: [String], default: [] },
  available_time: {
    start: { type: String },
    end: { type: String }
  },
  expected_salary: { type: Number, default: 0 },

  profile_image: { type: String },
  documents: [{ type: String }],
  // ในไฟล์ models/Maid.js


  status: { 
    type: String, 
    // อัปเดต enum ให้เป็นค่าใหม่ทั้งหมด
    enum: ['ว่าง', 'กำลังทำงาน', 'ลาพัก', 'รอตรวจสอบ', 'ระงับการใช้งาน'], 
    // กำหนดค่าเริ่มต้นสำหรับแม่บ้านใหม่เป็น 'รอตรวจสอบ'
    default: 'รอตรวจสอบ' 
  },
  // ... field อื่นๆ

  feedbacks: [{
    customer_id: String,
    rating: Number,
    comment: String,
    date: Date
  }],
  review_count: { type: Number, default: 0 },
  note: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Maid', maidSchema);