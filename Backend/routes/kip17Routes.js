const express = require("express");
const router = express.Router();

const kip17TokenMinting = require('../controller/kas/kip17/kip17TokenMinting');
const kip17TokenTransfer = require('../controller/kas/kip17/kip17TokenTransfer');
const kip17DeleteToken = require('../controller/kas/kip17/kip17DeleteToken');

router.post('/tokenMinting', kip17TokenMinting);
router.post('/tokenTransfer', kip17TokenTransfer);
router.delete('/deleteToken', kip17DeleteToken);

module.exports = router;