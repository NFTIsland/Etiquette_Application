const Market = require('../../model/market');

const search = async function (req, res) {
    try {
        Market.getSearch(req.params.keyword, function (err, row) {
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
                    msg: "검색 결과가 없습니다."
                });
            } else {
                res.status(402)
                res.json({
                    statusCode: 402,
                    msg: "경매 티켓 정보를 가져오지 못했습니다. 잠시 후 다시 시도해주세요."
                });                
            }
        });
    } catch (e) {
        console.error(e);
    }
}

module.exports = search;