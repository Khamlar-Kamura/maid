async function addressRoutes(fastify, options) {
  // ถ้าคุณมี Address Model จาก Mongoose ก็ import เข้ามา
  // const Address = require('../models/Address');

  /**
   * @route   POST /api/addresses
   * @desc    สร้างและบันทึกที่อยู่ใหม่
   * @access  Private (ต้อง Login ก่อน)
   */
  fastify.post('/', async (request, reply) => {
    try {
      // ดึงข้อมูลจาก request body ที่ส่งมาจาก Flutter
      const { name, placeName, phone, details, note, latitude, longitude } = request.body;

      // ตรวจสอบข้อมูลเบื้องต้น (สามารถเพิ่ม validation ที่ซับซ้อนกว่านี้ได้)
      if (!name || !placeName || !phone || !latitude || !longitude) {
        return reply.status(400).send({ message: 'กรุณากรอกข้อมูลที่จำเป็นให้ครบถ้วน' });
      }

      // TODO: บันทึกข้อมูลลง Database ของคุณ
      /*
      const newAddress = new Address({ ...ข้อมูล ... });
      const savedAddress = await newAddress.save();
      */

      console.log('ข้อมูลที่อยู่ใหม่ถูกสร้าง:', request.body);

      // ส่งข้อมูลกลับไปหา Client พร้อม status 201 (Created)
      reply.status(201).send({
        message: 'บันทึกที่อยู่สำเร็จ',
        data: request.body // ในสถานการณ์จริง ควรส่งข้อมูลที่ได้จาก Database กลับไป
      });

    } catch (error) {
      console.error('เกิดข้อผิดพลาดในการบันทึกที่อยู่:', error);
      reply.status(500).send({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
    }
  });
}

module.exports = addressRoutes;