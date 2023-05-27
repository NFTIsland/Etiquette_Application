const Ticket = require('../../model/ticket');
const Market = require('../../model/market');

const terminateAuction = async function (req, res) {
    try {
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
    } catch (e) {
        console.error(e);
    }
}

module.exports = terminateAuction;