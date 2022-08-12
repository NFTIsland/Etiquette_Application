const express = require("express");
const router = express.Router();

const metadataUpload = require('../controller/kas/metadata/metadataUpload');
const metadataLoad = require('../controller/kas/metadata/metadataLoad');

router.post('/metadataUpload', metadataUpload);
router.post('/metadataLoad', metadataLoad);

module.exports = router;