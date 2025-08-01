exports.calculatePrice = async (request, reply) => {
  const booking = request.body;
  let price = 0;
  if (typeof booking.hours === 'number' && !isNaN(booking.hours)) {
    price += 60000;
    if (booking.hours > 2) price += (booking.hours - 2) * 20000;
    if (booking.bedrooms > 1) price += (booking.bedrooms - 1) * 10000;
    if (booking.bathrooms > 1) price += (booking.bathrooms - 1) * 10000;
  }
  if (booking.otherRooms && Array.isArray(booking.otherRooms)) price += booking.otherRooms.length * 5000;
  const validServices = ["ironing", "cooking", "dishwashing", "babysitting"];
  let specialCount = 0;
  if (booking.specialServices && Array.isArray(booking.specialServices)) {
    specialCount = booking.specialServices.filter(s => validServices.includes(s)).length;
    price += specialCount * 20000;
  }
  reply.send({ price });
};