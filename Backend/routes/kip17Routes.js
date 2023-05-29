const express = require("express");
const router = express.Router();

const kip17TokenTransfer = require('../controller/kas/kip17/kip17TokenTransfer');
const kip17GetTokenData = require('../controller/kas/kip17/kip17GetTokenData');

router.post('/tokenTransfer', kip17TokenTransfer);
router.post('/getTokenData', kip17GetTokenData);

module.exports = router;