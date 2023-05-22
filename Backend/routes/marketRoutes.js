const express = require("express");
const router = express.Router();

const search = require("../controller/market/search");
const auctionInfo = require("../controller/market/auctionInfo");
const setTicketToBid = require("../controller/market/setTicketToBid");
const bid = require("../controller/market/bid");
const bidStatus = require("../controller/market/bidStatus");
const bidStatusTop5 = require("../controller/market/bidStatusTop5");
const top5RankBid = require("../controller/market/top5RankBid");
const deadLineTop5Auction = require("../controller/market/deadLineTop5Auction");
const deadLineAllAuction = require("../controller/market/deadLineAllAuction");
const terminateAuction = require("../controller/market/terminateAuction");

router.get('/search/:keyword', search);
router.post('/auctionInfo', auctionInfo);
router.post('/setTicketToBid', setTicketToBid);
router.post('/bid', bid);
router.post('/bidStatus', bidStatus);
router.post('/bidStatusTop5', bidStatusTop5);
router.get('/top5RankBid', top5RankBid);
router.get('/deadLineTop5Auction', deadLineTop5Auction);
router.get('/deadLineAllAuction', deadLineAllAuction);
router.delete('/terminateAuction', terminateAuction);

module.exports = router;