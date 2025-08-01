const User = require("../models/User");
const LoginUser = require("../models/LoginUser");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const twilio = require("twilio");
const twilioClient = twilio(
  process.env.TWILIO_SID,
  process.env.TWILIO_AUTH_TOKEN
);
const twilioPhone = process.env.TWILIO_PHONE;

// Mock OTP storage (ควรใช้ Redis หรือฐานข้อมูลจริงใน production)
const otpStore = {};

exports.sendOtp = async (request, reply) => {
  try {
    const { phone } = request.body;
    if (!phone) return reply.status(400).send({ error: "phone is required" });

    // สร้างเลข OTP 6 หลัก
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    otpStore[phone] = otp;

    // ส่ง OTP ไปยังเบอร์โทรจริงผ่าน Twilio
    await twilioClient.messages.create({
      body: `รหัส OTP ของคุณคือ: ${otp}`,
      from: twilioPhone,
      to: phone.startsWith("+") ? phone : `+856${phone.replace(/^0/, "")}`, // สำหรับเบอร์ลาว
    });
    reply.send({ message: "OTP sent" });
  } catch (err) {
    reply.status(500).send({ error: err.message });
  }
};

exports.registerWithOtp = async (request, reply) => {
  try {
    const { name, age, village, city, province, phone, email, password, otp, profile_image } = request.body;
    if (!phone || !otp)
      return reply.status(400).send({ error: "phone and otp are required" });

    // ตรวจสอบ OTP
    if (otpStore[phone] !== otp) {
      return reply.status(400).send({ error: "OTP ไม่ถูกต้อง" });
    }
    delete otpStore[phone];

    // ตรวจสอบซ้ำ
    const exist = await User.findOne({ phone });
    if (exist) return reply.status(400).send({ message: "Phone already exists" });

    const existEmail = await User.findOne({ email });
    if (existEmail)
      return reply.status(400).send({ message: "Email already exists" });

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = new User({
      name,
      age,
      village,
      city,
      province,
      phone,
      email,
      password: hashedPassword,
      profile_image,
    });
    await user.save();

    const { password: pw, ...userSafe } = user.toObject();
    reply.status(201).send({ message: "Register success", user: userSafe });
  } catch (err) {
    reply.status(400).send({ error: err.message });
  }
};

exports.login = async (request, reply) => {
  try {
    const { email, name, password } = request.body;

    let user;
    if (typeof email === "string" && email.trim()) {
      user = await User.findOne({ email: email.trim() });
    } else if (typeof name === "string" && name.trim()) {
      user = await User.findOne({ name: name.trim() });
    } else {
      return reply.status(400).send({ message: "Email or name is required" });
    }

    if (!user) {
      // ไม่เจอ user
      return reply
        .status(401)
        .send({ message: "ຊື່ ຫຼື ອີເມລຂອງທ່ານບໍ່ຖືກຕ້ອງ" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      // รหัสผ่านผิด
      return reply.status(401).send({ message: "ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ" });
    }
    await LoginUser.create({
      userId: user._id,
      name: user.name,
      loginAt: new Date(),
    });
    // สร้าง token ตามเดิม
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    const { password: pw, ...userSafe } = user.toObject();

    reply.send({
      message: "เข้าสู่ระบบสำเร็จ",
      token: token,
      user: userSafe,
    });
  } catch (err) {
    reply.status(500).send({ error: err.message });
  }
};