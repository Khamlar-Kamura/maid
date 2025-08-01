const Maid = require('../models/Maid');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname))
});
const upload = multer({ storage });

async function maidRoutes(fastify, options) {
  // GET: ดึงข้อมูลแม่บ้าน (แบ่งหน้า + ค้นหา)
  fastify.get('/', async (request, reply) => {
    try {
      const page = parseInt(request.query.page) || 1;
      const limit = parseInt(request.query.limit) || 10;
      const skip = (page - 1) * limit;
      const search = request.query.search || '';
      const query = {};
      if (search) {
        query.$or = [
          { full_name: { $regex: search, $options: 'i' } },
          { phone_number: { $regex: search, $options: 'i' } },
          { email: { $regex: search, $options: 'i' } },
          { address: { $regex: search, $options: 'i' } },
          { skills: { $regex: search, $options: 'i' } },
          { preferred_work_type: { $regex: search, $options: 'i' } },
        ];
      }
      const maidsPromise = Maid.find(query).skip(skip).limit(limit);
      const totalMaidsPromise = Maid.countDocuments(query);
      const [maids, total] = await Promise.all([maidsPromise, totalMaidsPromise]);
      reply.send({
        maids,
        totalPages: Math.ceil(total / limit),
        currentPage: page,
        totalMaids: total,
      });
    } catch (err) {
      reply.status(500).send({ error: 'Failed to fetch maids' });
    }
  });

  // GET: ดูข้อมูลแม่บ้านรายคน
  fastify.get('/:id', async (request, reply) => {
    try {
      const maid = await Maid.findOne({ maid_id: request.params.id });
      if (!maid) return reply.status(404).send({ error: 'ไม่พบแม่บ้าน' });
      reply.send(maid);
    } catch (err) {
      reply.status(400).send({ error: err.message });
    }
  });

  // POST: สร้างแม่บ้านใหม่
  fastify.post('/', async (request, reply) => {
    try {
      const {
        full_name, phone_number, email, address, location, gender, age, skills,
        experience_years, preferred_work_type, available_days, available_time,
        expected_salary, is_active, profile_image, documents, status,
        feedbacks, review_count, note
      } = request.body;

      if (!full_name || !phone_number) {
        return reply.status(400).send({ error: 'full_name และ phone_number จำเป็นต้องมี' });
      }

      const maid_id = Math.floor(100000 + Math.random() * 900000).toString();
      const maidData = {
        maid_id, full_name, phone_number, email, address, location, gender, age, skills,
        experience_years, preferred_work_type, available_days, available_time,
        expected_salary, is_active, profile_image, documents, status,
        feedbacks, review_count, note
      };

      const maid = await Maid.create(maidData);
      reply.status(201).send(maid);
    } catch (err) {
      reply.status(400).send({ error: err.message });
    }
  });

  // PUT: แก้ไขข้อมูลแม่บ้าน
  fastify.put('/:id', async (request, reply) => {
    try {
      const maid = await Maid.findOneAndUpdate(
        { maid_id: request.params.id },
        request.body,
        { new: true }
      );
      if (!maid) return reply.status(404).send({ error: 'ไม่พบแม่บ้าน' });
      reply.send(maid);
    } catch (err) {
      reply.status(400).send({ error: err.message });
    }
  });

  // DELETE: ลบแม่บ้าน
  fastify.delete('/:id', async (request, reply) => {
    try {
      const maid = await Maid.findOneAndDelete({ maid_id: request.params.id });
      if (!maid) return reply.status(404).send({ error: 'ไม่พบแม่บ้าน' });
      reply.send({ message: 'ลบแม่บ้านแล้ว' });
    } catch (err) {
      reply.status(500).send({ error: 'Failed to delete maid' });
    }
  });

  // POST: อัปโหลดรูปโปรไฟล์แม่บ้าน (ใช้ fastify-multer)
  fastify.post('/:id/profile-image', { preHandler: upload.single('profile_image') }, async (request, reply) => {
    try {
      const maid = await Maid.findOne({ maid_id: request.params.id });
      if (!maid) return reply.status(404).send({ error: 'ไม่พบแม่บ้าน' });
      maid.profile_image = '/uploads/' + request.file.filename;
      const savedMaid = await maid.save();
      reply.send(savedMaid);
    } catch (err) {
      reply.status(500).send({ error: err.message });
    }
  });

  // POST: เพิ่ม feedback ให้แม่บ้าน
  fastify.post('/:id/feedback', async (request, reply) => {
    try {
      const { customer_id, rating, comment } = request.body;
      const maid = await Maid.findOne({ maid_id: request.params.id });
      if (!maid) return reply.status(404).send({ error: 'ไม่พบแม่บ้าน' });
      maid.feedbacks.push({ customer_id, rating, comment, date: new Date() });
      maid.review_count = maid.feedbacks.length;
      await maid.save();
      reply.send(maid);
    } catch (err) {
      reply.status(400).send({ error: err.message });
    }
  });
}

module.exports = maidRoutes;