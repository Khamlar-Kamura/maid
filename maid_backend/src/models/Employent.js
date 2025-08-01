const mongoose = require('mongoose');

const employmentSchema = new mongoose.Schema({
  job_id: { type: String, required: true, unique: true },
  maid_id: { type: String, required: true, ref: 'Maid' },
  customer_id: { type: String, required: true, ref: 'User' },
  work_dates: [{ type: String }], // เช่น ["2025-07-01"]
  work_time: {
    start: { type: String }, // "08:00"
    end: { type: String }    // "16:00"
  },
  location: { type: String },
  tasks: [{ type: String }],
  salary_per_day: { type: Number },
  total_salary: { type: Number },
  status: { 
    type: String, 
    enum: ['รอดำเนินการ', 'จ้างแล้ว', 'เสร็จสิ้น', 'ยกเลิก'], 
    default: 'รอดำเนินการ' 
  },
  note: { type: String },
  feedback: {
    rating: Number,
    comment: String
  },
  is_confirmed: { type: Boolean, default: false },
  cancel_reason: { type: String },
  created_by: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Employment', employmentSchema);