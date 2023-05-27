const Market = require('../../model/market');

const auctionInfo = async function (req, res) {
    try {
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
                    msg: "경매 티켓 정보를 가져오지 못했습니다. 잠시 후 다시 시도해주세요."
                });
                console.log(`auctionInfo: ${err}`);
            }
        });
    } catch (e) {
        console.error(e);
    }
}

module.exports = auctionInfo;