const Booking = require('../models/Booking');
const authMiddleware = require('../middleware/authMiddleware');

async function bookingRoutes(fastify, options) {
fastify.get('/my-bookings', { preHandler: authMiddleware }, async (request, reply) => {
  try {
    const bookings = await Booking.find({ user_id: request.user.id }).sort({ booking_date: -1 });
    reply.send(bookings);
  } catch (err) {
    reply.status(500).send({ message: 'Server Error', error: err.message });
  }
});
  
  

  // POST /api/bookings
  // filepath: c:\maid\maid_backend\src\routes\bookingRoutes.js
fastify.post('/', { preHandler: authMiddleware }, async (request, reply) => {
  try {
    const booking = request.body;
    booking.user_id = request.user.id;
    const savedBooking = await Booking.create(booking);
    if (!savedBooking) {
      return reply.status(500).send({ message: 'Booking not saved' });
    }
    reply.status(201).send({ booking: savedBooking });
  } catch (err) {
    reply.status(500).send({ message: 'Server Error', error: err.message });
  }
});
}

module.exports = bookingRoutes;