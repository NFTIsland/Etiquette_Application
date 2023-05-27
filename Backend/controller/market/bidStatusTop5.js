const Market = require('../../model/market');

const bidStatusTop5 = async function (req, res) {
    try {
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
                    msg: "입찰 정보를 가져오지 못했습니다. 다시 시도해주세요."
                });
                console.log(`bidStatusTop5: ${err}`);
            }
        });
    } catch (e) {
        console.error(e);
    }
}

module.exports = bidStatusTop5;