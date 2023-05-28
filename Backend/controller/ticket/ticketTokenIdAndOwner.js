const Ticket = require('../../model/ticket');

const ticketTokenIdAndOwner = async function (req, res) {
    try {
        Ticket.getTicketTokenIdAndOwner(req.body.product_name, req.body.place, req.body.date, req.body.time, req.body.seat_class, req.body.seat_No, function (err, row) {
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
                    msg: "서버와의 상태가 원활하지 않습니다. 잠시 후 다시 시도해주세요."
                });
                console.log(`ticketTokenIdAndOwner: ${err}`);
            }
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = ticketTokenIdAndOwner;