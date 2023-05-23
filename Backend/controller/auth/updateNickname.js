const Auth = require("../../model/auth");

const updateNickname = async function (req, res) {
    try {
        Auth.updateNickName(req.body.id, req.body.nickname, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({
                    statusCode: 200
                });
            } else {
                res.status(401);
                res.json({
                    statusCode: 401,
                    msg: "닉네임 변경에 실패했습니다."
                });
                console.log(`updateNickname: ${err}`);
            }
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = updateNickname;