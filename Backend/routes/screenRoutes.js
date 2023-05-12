const express = require("express");
const router = express.Router();

const homePosters = require('../controller/screen/homePosters');
const homeNotices = require('../controller/screen/homeNotices');
const backdropImages = require('../controller/screen/backdropImages');

router.get('/homePosters', homePosters);
router.get('/homeNotices', homeNotices);
router.get('/backdropImages', backdropImages);

module.exports = router;