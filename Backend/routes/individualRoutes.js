const express = require("express");
const router = express.Router();
const individualController = require("../controller/individualController");

router.post('/holdlist', individualController.holdlist);
router.post('/sellinglist', individualController.sellinglist);
router.post('/usedlist', individualController.usedlist);
router.post('/interestTicketing', individualController.interestTicketing);
router.delete('/uninterestTicketing', individualController.uninterestTicketing);
router.post('/interestAuction', individualController.interestAuction);
router.delete('/uninterestAuction', individualController.uninterestAuction);
router.post('/interestTicketinglist', individualController.interestTicketinglist);
router.post('/interestAuctionlist', individualController.interestAuctionlist);
router.post('/isInterestedTicketing', individualController.isInterestedTicketing);
router.post('/isInterestedAuction', individualController.isInterestedAuction);

module.exports = router;