const Ticket = require('../../model/ticket');

const deadLineAll = async function (req, res) {
    try {
        Ticket.getAllDeadline(function (err, row) {
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
                    msg: "서버와의 상태가 원활하지 않습니다. 잠시 후 다시 시도해주세요."
                });
                console.log(`deadLineAll: ${err}`);
            }
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = deadLineAll;