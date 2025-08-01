require("dotenv").config();
const fastify = require("fastify")({
  logger: true,
  bodyLimit: 10 * 1024 * 1024 // 5MB หรือปรับตามต้องการ
});
const fastifyCors = require("@fastify/cors");
const connectDB = require("./config/db");
const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const adminRoutes = require("./routes/adminRoutes");
const maidRoutes = require("./routes/maidRoutes");
const bookingRoutes = require("./routes/bookingRoutes");
const addressRoutes = require("./routes/addressRoutes");
const pricingRoutes = require("./routes/pricingRoutes");

const PORT = process.env.PORT || 5000;

// CORS
fastify.register(fastifyCors, {
  origin: [
    "http://localhost:8000",
    "http://localhost:3000",
    "http://172.20.10.2:3000",
    "http://172.20.10.2:8000",
    "https://370d0a42e8c5.ngrok-free.app"
  ],
  credentials: true,
});

// Middleware log request
fastify.addHook("onRequest", async (request, reply) => {
  fastify.log.info(`--- Incoming Request ---`);
  fastify.log.info(`Method: ${request.method}`);
  fastify.log.info(`URL: ${request.url}`);
  fastify.log.info(`Headers: ${JSON.stringify(request.headers)}`);
});

// เชื่อมต่อฐานข้อมูล
connectDB(fastify);

// Static files (เช่น /uploads)
fastify.register(require("@fastify/static"), {
  root: require("path").join(__dirname, "../uploads"),
  prefix: "/uploads/",
});

// Register routes (ต้องแปลงแต่ละไฟล์ route ให้เป็น fastify plugin หรือใช้ fastify-express)
fastify.register(authRoutes, { prefix: "/auth" });
fastify.register(userRoutes, { prefix: "/users" });
fastify.register(maidRoutes, { prefix: "/maids" });
fastify.register(adminRoutes, { prefix: "/admin" });
fastify.register(maidRoutes, { prefix: "/api/maids" });
fastify.register(pricingRoutes, { prefix: "/api/pricing" });
fastify.register(bookingRoutes, { prefix: "/api/bookings" });
fastify.register(addressRoutes, { prefix: "/api/addresses" });


// /status
fastify.get("/status", async (request, reply) => {
  const mongoose = require("mongoose");
  if (mongoose.connection.readyState === 1) {
    return { status: "Welcome to Maid APP" };
  } else {
    return { status: "Not connected" };
  }
});

// /admin/health
fastify.get("/admin/health", async (request, reply) => {
  return { status: "Admin API working" };
});

// 404 handler
fastify.setNotFoundHandler((request, reply) => {
  reply.status(404).send({ error: "API endpoint not found" });
});

// Start server
fastify.listen({ port: PORT, host: "0.0.0.0" }, (err, address) => {
  if (err) {
    fastify.log.error(err);
    process.exit(1);
  }
  fastify.log.info(`HTTP Server running on ${address}`);
});