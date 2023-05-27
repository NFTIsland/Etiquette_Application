const Market = require('../../model/market');

const top5RankBid = async function (req, res) {
    try {
        Market.getTop5RankBid(function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    data: row
                });
            } else {
                res.status(402)
                res.json({
                    statusCode: 402,
                    msg: "서버 상태가 원활하지 않습니다. 잠시 후 시도해주세요."
                });
                console.log(`top5RankBid: ${err}`);
            }
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = top5RankBid;