const express = require("express");
const router = express.Router();

const createAccount = require('../controller/kas/wallet/createAccount');
const checkAccount = require('../controller/kas/wallet/checkAccount');
const deleteAccount = require('../controller/kas/wallet/deleteAccount');
const getBalance = require('../controller/kas/wallet/getBalance');
const transactionRetrieve = require('../controller/kas/wallet/transactionRetrieve');
const klayTransaction = require('../controller/kas/wallet/klayTransaction');

router.post('/createAccount', createAccount);
router.get('/checkAccount/', checkAccount);
router.get('/checkAccount/:address', checkAccount);
router.delete('/deleteAccount/', deleteAccount);
router.delete('/deleteAccount/:address', deleteAccount);
router.post('/getBalance', getBalance);
router.get('/transactionRetrieve/:transactionHash', transactionRetrieve);
router.post('/klayTransaction', klayTransaction);

module.exports = router;