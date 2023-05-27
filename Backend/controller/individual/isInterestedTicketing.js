const Individual = require('../../model/individual');

const isInterestedTicketing = async function (req, res) {
    try {
        Individual.getIsInterestedTicketing(req.body.product_name, req.body.place, req.body.kas_address, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    data: true
                });
            } else if (row != undefined) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    data: false
                });
            } else {
                res.status(401)
                res.json({
                    statusCode: 401,
                    msg: "서버와의 상태가 원활하지 않습니다. 잠시 후 다시 시도해주세요."
                });
                console.log(`isInterestedTicketing: ${err}`);
            }
        })
    } catch (e) {
        console.error(e)
    }
}

module.exports = isInterestedTicketing;