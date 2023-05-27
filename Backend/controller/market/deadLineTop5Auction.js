const Market = require('../../model/market');

const deadLineTop5Auction = async function (req, res) {
    try {
        Market.get5DeadlineAuction(function (err, row) {
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
                console.log(`deadLineTop5Auction: ${err}`);
            }
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = deadLineTop5Auction;