const express = require("express");
const router = express.Router();
const ticketController = require("../controller/ticketController");

router.get('/ticketInfo', ticketController.ticketInfo);
router.get('/ticketPriceInfo/:product_name', ticketController.ticketPriceInfo);
router.get('/ticketDescription/:product_name', ticketController.ticketDescription);
router.get('/ticketPerformanceDate/:product_name/:place', ticketController.ticketPerformanceDate);
router.get('/ticketPerformanceTime/:product_name/:place/:date', ticketController.ticketPerformanceTime);
router.get('/ticketSeatClass/:product_name/:place/:date/:time', ticketController.ticketSeatClass);
router.get('/ticketSeatNo/:product_name/:place/:date/:time/:seat_class', ticketController.ticketSeatNo);
router.get('/ticketPrice/:product_name/:seat_class', ticketController.ticketPrice);
router.get('/ticketTokenIdAndOwner/:product_name/:place/:date/:time/:seat_class/:seat_No', ticketController.ticketTokenIdAndOwner);
router.post('/updateTicketOwner', ticketController.updateTicketOwner);
router.get('/ticketSeatImageUrl/:product_name/:place', ticketController.ticketSeatImageUrl);

module.exports = router;