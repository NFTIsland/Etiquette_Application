const Ticket = require('../../model/ticket');

const ticketDescription = async function (req, res) {
    try {
        Ticket.getTicketDescription(req.params.product_name, function (err, row) {
            if (row != undefined && row.length) {
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
                console.log(`ticketDescription: ${err}`);
            }
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = ticketDescription;