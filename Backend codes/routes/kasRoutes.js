const express = require("express");
const router = express.Router();

const walletRouter = require('./walletRoutes');
router.use('/wallet', walletRouter);

module.exports = router;