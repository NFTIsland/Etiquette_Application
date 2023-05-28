const Ticket = require('../../model/ticket');

const updateTicketOwner = async function (req, res) {
    try {
        Ticket.setUpdateTicketOwner(req.body.owner, req.body.token_id, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({
                    statusCode: 200
                });
            } else {
                res.status(401)
                res.json({
                    statusCode: 401,
                    msg: "서버와의 상태가 원활하지 않습니다. 잠시 후 다시 시도해주세요."
                });
                console.log(`updateTicketOwner: ${err}`);
            }
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = updateTicketOwner;