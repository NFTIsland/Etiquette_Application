const Market = require('../../model/market');

const deadLineAllAuction = async function (req, res) {
    try {
        Market.getAllDeadlineAuction(function (err, row) {
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
                console.log(`deadLineAllAuction: ${err}`);
            }
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = deadLineAllAuction;