const Market = require('../model/market');
const Ticket = require('../model/ticket');

module.exports = {
    search: function (req, res) {
        Market.getSearch(req.params.keyword, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    data: row
                });
            } else {
                res.status(402)
                res.json({
                    statusCode: 402,
                    msg: "Failed to retrieve tickets from DB"
                });
            }
        });
    },

    auctionInfo: function (req, res) {
        Market.getAuctionInfo(req.body.token_id, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    data: row
                });
            } else if (row != undefined) {
                res.status(201);
                res.json({
                    statusCode: 201,
                    msg: "경매가 마감된 티켓입니다.",
                });
            } else {
                res.status(402)
                res.json({
                    statusCode: 402,
                    msg: "Failed to retrieve tickets from DB"
                });
            }
        });
    },

    setTicketToBid: function (req, res) {
        Market.uploadTicketToBid(
            req.body.token_id, 
            req.body.auction_start_price, 
            req.body.bid_unit, 
            req.body.immediate_purchase_price, 
            req.body.auction_end_date, 
            req.body.auction_comments, 
            function (err, row) {
                if (!err) {
                    res.status(200);
                    res.json({statusCode: 200});
                } else {
                    res.status(408)
                    res.json({statusCode: 408, msg: "Failed to update DB"});
                    console.log(`uploadTicketToBid: ${err}`);
                }
            }
        )
    },

    bid: function (req, res) {
        Market.doBid(req.body.token_id, req.body.bidder, req.body.bid_price, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({
                    statusCode: 200
                });
            } else {
                res.status(402)
                res.json({
                    statusCode: 402,
                    msg: err
                });
            }
        });
    },

    bidStatus: function (req, res) {
        Market.getBidStatus(req.body.token_id, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    data: row
                });
            } else {
                res.status(402)
                res.json({
                    statusCode: 402,
                    msg: err
                });
            }
        });
    },

    bidStatusTop5: function (req, res) {
        Market.getBidStatusTop5(req.body.token_id, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    data: row
                });
            } else {
                res.status(402)
                res.json({
                    statusCode: 402,
                    msg: err
                });
            }
        });
    },

    top5RankBid: function (req, res) {
        Market.getTop5RankBid(function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(402)
                res.json({statusCode: 402, msg: "Failed to get top 5 rank bid from DB"});
            }
        })
    },

    deadLineTop5Auction: function (req, res) {
        Market.get5DeadlineAuction(function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(402)
                res.json({statusCode: 402, msg: "Failed to get deadline imminent auction tickets from DB"});
            }
        })
    },

    deadLineAllAuction: function (req, res) {
        Market.getAllDeadlineAuction(function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(402)
                res.json({statusCode: 402, msg: "Failed to get deadline imminent auction tickets from DB"});
            }
        })
    },

    terminateAuction: function (req, res) {
        Ticket.getOwner(req.body.token_id, function (err, row) {
            if (row != undefined && row.length) {
                if (req.body.bidder = row['data'][0]['owner']) {
                    Market.delAuctionData(req.body.token_id, function (err, row) {
                        if (!err) {
                            res.status(200);
                            res.json({
                                statusCode: 200,
                                data: row
                            });
                        } else {
                            res.status(402)
                            res.json({
                                statusCode: 402,
                                msg: err
                            });
                        }
                    });
                } else {
                    res.status(402);
                    res.json({
                        statusCode: 402,
                        msg: "비정상적인 접근입니다."
                    });
                }
            } else {
                res.status(402)
                res.json({
                    statusCode: 402,
                    msg: "Failed to retrieve owner from DB"
                });
            }
        })
    }
}