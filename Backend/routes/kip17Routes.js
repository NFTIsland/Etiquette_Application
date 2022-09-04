const express = require("express");
const router = express.Router();

const kip17TokenMinting = require('../controller/kas/kip17/kip17TokenMinting');
const kip17TokenTransfer = require('../controller/kas/kip17/kip17TokenTransfer');
const kip17DeleteToken = require('../controller/kas/kip17/kip17DeleteToken');
const kip17GetTokenData = require('../controller/kas/kip17/kip17GetTokenData');

router.post('/tokenMinting', kip17TokenMinting);
router.post('/tokenTransfer', kip17TokenTransfer);
router.delete('/deleteToken', kip17DeleteToken);
router.post('/getTokenData', kip17GetTokenData);

module.exports = router;