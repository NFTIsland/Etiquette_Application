const Individual = require('../model/individual');

module.exports = {
    holdlist: function (req, res) {
        Individual.getHoldlist(req.body.kas_address, function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(405)
                res.json({statusCode: 405, msg: "Failed to retrieve hold tickets from DB"});
            }
        });
    },

    sellinglist: function (req, res) {
        Individual.getSellinglist(req.body.kas_address, function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(405)
                res.json({statusCode: 405, msg: "Failed to retrieve selling tickets from DB"});
            }
        });
    },

    usedlist: function (req, res) {
        Individual.getUsedlist(req.body.kas_address, function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(405)
                res.json({statusCode: 405, msg: "Failed to retrieve used tickets from DB"});
            }
        });
    },

    interestTicketing: function (req, res) {
        Individual.setInterestTicketing(req.body.product_name, req.body.place, req.body.kas_address, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({statusCode: 200});
            } else {
                res.status(405)
                res.json({statusCode: 405, msg: "Failed to update interest ticket into DB"});
            }
        });
    },

    uninterestTicketing: function (req, res) {
        Individual.delInterestTicketing(req.body.product_name, req.body.place, req.body.kas_address, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({statusCode: 200});
            } else {
                res.status(405)
                res.json({statusCode: 405, msg: "Failed to delete interest ticket from DB"});
            }
        });
    },

    interestAuction: function (req, res) {
        Individual.setInterestAuction(req.body.product_name, req.body.place, req.body.seat_class, req.body.seat_No, req.body.kas_address, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({statusCode: 200});
            } else {
                res.status(405)
                res.json({statusCode: 405, msg: "Failed to update interest ticket into DB"});
            }
        });
    },

    uninterestAuction: function (req, res) {
        Individual.delInterestAuction(req.body.product_name, req.body.place, req.body.seat_class, req.body.seat_No, req.body.kas_address, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({statusCode: 200});
            } else {
                res.status(405)
                res.json({statusCode: 405, msg: "Failed to update interest ticket into DB"});
            }
        });
    },

    interestTicketinglist: function (req, res) {
        Individual.getInterestTicketing(req.body.kas_address, function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(405)
                res.json({statusCode: 405, msg: "Failed to retrieve interest tickets from DB"});
            }
        });
    },

    interestAuctionlist: function (req, res) {
        Individual.getInterestAuction(req.body.kas_address, function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(405)
                res.json({statusCode: 405, msg: "Failed to retrieve interest tickets from DB"});
            }
        });
    },

    isInterestedTicketing: function (req, res) {
        Individual.getIsInterestedTicketing(req.body.product_name, req.body.place, req.body.kas_address, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: true});
            } else if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: false});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to get is interested from DB"});
            }
        })
    },

    isInterestedAuction: function (req, res) {
        Individual.getIsInterestedAuction(req.body.product_name, req.body.place, req.body.seat_class, req.body.seat_No, req.body.kas_address, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: true});
            } else if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: false});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to get is interested from DB"});
            }
        })
    },
}