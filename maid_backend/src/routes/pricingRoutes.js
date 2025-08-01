const pricingController = require('../controllers/pricingController');

async function pricingRoutes(fastify, options) {
  // POST /api/pricing/calculate
  fastify.post('/calculate', async (request, reply) => {
    return pricingController.calculatePrice(request, reply);
  });
}

module.exports = pricingRoutes;