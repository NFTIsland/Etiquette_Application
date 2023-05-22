const express = require("express");
const router = express.Router();

const getEmail = require("../controller/individual/getEmail");
const interestTicketing = require("../controller/individual/interestTicketing");
const uninterestTicketing = require("../controller/individual/uninterestTicketing");
const interestTicketinglist = require("../controller/individual/interestTicketinglist");
const interestAuction = require("../controller/individual/interestAuction");
const uninterestAuction = require("../controller/individual/uninterestAuction");
const interestAuctionlist = require("../controller/individual/interestAuctionlist");
const holdlist = require("../controller/individual/holdlist");
const bidlist = require("../controller/individual/bidlist");
const sellinglist = require("../controller/individual/sellinglist");
const holdCounts = require("../controller/individual/holdCounts");
const auctionCounts = require("../controller/individual/auctionCounts");
const usedlist = require("../controller/individual/usedlist");
const isInterestedTicketing = require("../controller/individual/isInterestedTicketing");
const isInterestedAuction = require("../controller/individual/isInterestedAuction");

router.post('/getEmail', getEmail);
router.post('/interestTicketing', interestTicketing);
router.delete('/uninterestTicketing', uninterestTicketing);
router.post('/interestTicketinglist', interestTicketinglist);
router.post('/interestAuction', interestAuction);
router.delete('/uninterestAuction', uninterestAuction);
router.post('/interestAuctionlist', interestAuctionlist);
router.post('/holdlist', holdlist);
router.post('/bidlist', bidlist);
router.post('/sellinglist', sellinglist);
router.post('/holdCounts', holdCounts);
router.post('/auctionCounts', auctionCounts);
router.post('/usedlist', usedlist);
router.post('/isInterestedTicketing', isInterestedTicketing);
router.post('/isInterestedAuction', isInterestedAuction);

module.exports = router;