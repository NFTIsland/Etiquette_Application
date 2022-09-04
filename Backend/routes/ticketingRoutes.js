const express = require("express");
const router = express.Router();
const ticketController = require("../controller/ticketController");

router.get('/search/:keyword', ticketController.search);
router.get('/hotPick', ticketController.hotPick);
router.get('/deadLineTop5', ticketController.deadLineTop5);
router.get('/deadLineAll', ticketController.deadLineAll);

module.exports = router;