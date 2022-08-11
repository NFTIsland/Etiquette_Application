const express = require("express");
const router = express.Router();

const walletRouter = require('./walletRoutes');
router.use('/wallet', walletRouter);

const metadataRouter = require('./metadataRoutes');
router.use('/metadata', metadataRouter);

const kip17Router = require('./kip17Routes');
router.use('/kip17', kip17Router);

module.exports = router;