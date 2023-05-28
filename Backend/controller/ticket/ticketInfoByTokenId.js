const Ticket = require('../../model/ticket');

const ticketInfoByTokenId = async function (req, res) {
    try {
        Ticket.getTicketInfoByTokenId(req.params.token_id, function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    data: row
                });
            } else {
                res.status(401)
                res.json({
                    statusCode: 401,
                    msg: "티켓 정보를 가져오지 못했습니다. 잠시 후 다시 시도해주세요."
                });
                console.log(`ticketInfoByTokenId: ${err}`);
            }
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = ticketInfoByTokenId;