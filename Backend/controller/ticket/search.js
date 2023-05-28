const Ticket = require('../../model/ticket');

const search = async function (req, res) {
    try {
        Ticket.getSearch(req.params.keyword, function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    data: row
                });
            } else {
                res.status(401);
                res.json({
                    statusCode: 401,
                    msg: "티켓 정보를 가져오지 못했습니다. 잠시후 다시 시도해주세요."
                });
                console.log(`search: ${err}`);
            }
        });
    } catch (e) {
        console.error(e);
    }
}

module.exports = search;