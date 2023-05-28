const Ticket = require('../../model/ticket');

const ticketInfo = async function (req, res) {
    try {
        Ticket.getTicketInfo(function (err, row) {
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
                    msg: "Failed to retrieve tickets from DB"
                });
                console.log(`ticketInfo: ${err}`);
            }
        });
    } catch (e) {
        console.error(e);
    }
}

module.exports = ticketInfo;