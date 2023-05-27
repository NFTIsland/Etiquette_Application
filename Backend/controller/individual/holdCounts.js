const Individual = require('../../model/individual');

const holdCounts = async function (req, res) {
    try {
        Individual.getNumberOfHoldingTickets(req.body.kas_address, function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    data: row
                });
            } else {
                res.status(405)
                res.json({
                    statusCode: 405,
                    msg: "서버와의 상태가 원활하지 않습니다. 잠시 후 다시 시도해주세요."
                });
                console.log(`holdCounts: ${err}`);
            }
        });
    } catch (e) {
        console.error(e)
    }
}

module.exports = holdCounts;