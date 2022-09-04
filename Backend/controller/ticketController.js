const Ticket = require('../model/ticket');

module.exports = {
    search: function (req, res) {
        Ticket.getSearch(req.params.keyword, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to retrieve tickets from DB"});
            }
        });
    },

    ticketInfo: function (req, res) {
        Ticket.getTicketInfo(function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to retrieve tickets from DB"});
            }
        });
    },

    ticketPriceInfo: function (req, res) {
        Ticket.getTicketPriceInfo(req.params.product_name, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to retrieve tickets from DB"});
            }
        })
    },

    ticketDescription: function (req, res) {
        Ticket.getTicketDescription(req.params.product_name, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to retrieve tickets from DB"});
            }
        })
    },

    ticketPerformanceDate: function (req, res) {
        Ticket.getTicketPerformanceDate(req.params.product_name, req.params.place, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to retrieve tickets from DB"});
            }
        })
    },

    ticketPerformanceTime: function (req, res) {
        Ticket.getTicketPerformanceTime(req.params.product_name, req.params.place, req.params.date, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to retrieve tickets from DB"});
            }
        })
    },

    ticketSeatClass: function (req, res) {
        Ticket.getSeatClass(req.params.product_name, req.params.place, req.params.date, req.params.time, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to retrieve tickets from DB"});
            }
        })
    },

    ticketSeatNo: function (req, res) {
        Ticket.getSeatNo(req.params.product_name, req.params.place, req.params.date, req.params.time, req.params.seat_class, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to retrieve tickets from DB"});
            }
        })
    },

    ticketPrice: function (req, res) {
        Ticket.getPrice(req.params.product_name, req.params.seat_class, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to retrieve tickets from DB"});
            }
        })
    },

    ticketSeatImageUrl: function (req, res) {
        Ticket.getTicketSeatImageUrl(req.params.product_name, req.params.place, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to seat image url from DB"});
            }
        })
    },

    ticketTokenIdAndOwner: function (req, res) {
        Ticket.getTicketTokenIdAndOwner(req.params.product_name, req.params.place, req.params.date, req.params.time, req.params.seat_class, req.params.seat_No, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to get token_id and owner from DB"});
            }
        })
    },

    updateTicketOwner: function (req, res) {
        Ticket.setUpdateTicketOwner(req.body.owner, req.body.token_id, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({statusCode: 200});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to update DB"});
                console.log(`updateTicketOwner: ${err}`);
            }
        })
    },

    hotPick: function (req, res) {
        Ticket.getHotPick(function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to get hot pick from DB"});
            }
        })
    },

    deadLineTop5: function (req, res) {
        Ticket.get5Deadline(function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to get deadline top 5 from DB"});
            }
        })
    },

    deadLineAll: function (req, res) {
        Ticket.getAllDeadline(function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(401)
                res.json({statusCode: 401, msg: "Failed to get deadline from DB"});
            }
        })
    },
}
