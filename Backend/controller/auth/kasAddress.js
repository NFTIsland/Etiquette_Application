const Auth = require("../../model/auth");

const kasAddress = async function (req, res) {
    try {
        Auth.getKasAddress(req.body.id, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    data: row
                });
            } else {
                res.status(404);
                res.json({
                    statusCode: 404,
                    msg: "KAS 주소 정보를 가져오지 못했습니다."
                });
            }
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = kasAddress;