const express = require("express");
const router = express.Router();
const screenController = require("../controller/screenController");

router.get('/homePosters', screenController.homePosters);
router.get('/homeNotices', screenController.homeNotices);

module.exports = router;