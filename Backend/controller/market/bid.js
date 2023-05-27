const Market = require('../../model/market');

const bid = async function (req, res) {
    try {
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
                    msg: "입찰에 실패했습니다. 다시 시도해주세요."
                });
                console.log(`bid: ${err}`);
            }
        });
    } catch (e) {
        console.error(e);
    }
}

module.exports = bid;