const express = require("express");
const router = express.Router();

const createAccount = require('../controller/kas/wallet/createAccount');
const checkAccount = require('../controller/kas/wallet/checkAccount');

router.post('/createAccount', createAccount);
router.get('/checkAccount/:address', checkAccount);

module.exports = router;