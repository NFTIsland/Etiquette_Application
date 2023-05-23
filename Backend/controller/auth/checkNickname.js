const Auth = require("../../model/auth");

const checkNickname = async function (req, res) {
    try {
        Auth.selectNickname(req.body.nickname, function (err, row) {
            if (row != undefined && row.length) {
                res.status(409);
                res.json({
                    statusCode: 409,
                    msg: "이미 존재하는 닉네임입니다."
                });
            } else {
                res.status(200);
                res.json({
                    statusCode: 200,
                    msg: "사용할 수 있는 닉네임입니다."
                });
            }
        });
    } catch (e) {
        console.error(e);
    }
}

module.exports = checkNickname;