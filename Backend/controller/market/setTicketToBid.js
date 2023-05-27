const Market = require('../../model/market');

const setTicketToBid = async function (req, res) {
    try {
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
                    res.json({
                        statusCode: 200
                    });
                } else {
                    res.status(408)
                    res.json({
                        statusCode: 408,
                        msg: "티켓 업로드에 실패했습니다. 다시 시도해주세요."
                    });
                    console.log(`uploadTicketToBid: ${err}`);
                }
            }
        )
    } catch (e) {
        console.error(e);
    }
}

module.exports = setTicketToBid;