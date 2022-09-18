const express = require("express");
const router = express.Router();
const schedulerController = require("../controller/schedulerController");

router.post('/auctionSchedule', schedulerController.auctionSchedule);

module.exports = router;