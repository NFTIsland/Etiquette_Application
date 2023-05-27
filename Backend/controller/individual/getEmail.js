const Individual = require('../../model/individual');

const getEmail = async function (req, res) {
    try {
        Individual.getMyEmail(req.body.id, function (err, row) {
            if (row != undefined) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    email: row.at(0)['email']
                });
            } else {
                res.status(405)
                res.json({
                    statusCode: 405,
                    msg: "이메일 주소를 찾지 못했습니다. 다시 등록해주세요."
                });
                console.log(`getEmail: ${err}`);
            }
        });
    } catch (e) {
        console.error(e)
    }
}

module.exports = getEmail;