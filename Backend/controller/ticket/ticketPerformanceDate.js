const Ticket = require('../../model/ticket');

const ticketPerformanceDate = async function (req, res) {
    try {
        Ticket.getTicketPerformanceDate(req.body.product_name, req.body.place, function (err, row) {
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
                console.log(`ticketPerformanceDate: ${err}`);
            }
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = ticketPerformanceDate;