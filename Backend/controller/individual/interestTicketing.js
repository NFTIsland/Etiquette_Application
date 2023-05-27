const Individual = require('../../model/individual');

const interestTicketing = async function (req, res) {
    try {
        Individual.setInterestTicketing(req.body.product_name, req.body.place, req.body.kas_address, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({
                    statusCode: 200
                });
            } else {
                res.status(405)
                res.json({
                    statusCode: 405,
                    msg: "서버와의 상태가 원활하지 않습니다. 잠시 후 다시 시도해주세요."
                });
                console.log(`interestTicketing: ${err}`);
            }
        });
    } catch (e) {
        console.error(e)
    }
}

module.exports = interestTicketing;