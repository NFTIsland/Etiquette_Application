const express = require("express");
const router = express.Router();
const marketController = require("../controller/marketController");

router.get('/search/:keyword', marketController.search);
router.post('/auctionInfo', marketController.auctionInfo);
router.post('/setTicketToBid', marketController.setTicketToBid);
router.post('/bid', marketController.bid);
router.post('/bidStatus', marketController.bidStatus);
router.post('/bidStatusTop5', marketController.bidStatusTop5);
router.get('/top5RankBid', marketController.top5RankBid);
router.get('/deadLineTop5Auction', marketController.deadLineTop5Auction);
router.get('/deadLineAllAuction', marketController.deadLineAllAuction);
router.delete('/terminateAuction', marketController.terminateAuction);

// const marketGeneralRouter = require("./marketGeneralRoutes");
// router.use("/general", marketGeneralRouter);

module.exports = router;