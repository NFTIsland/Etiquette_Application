const Auth = require("../../model/auth");

const updatePassword = async function (req, res) {
    try {
        Auth.updatePW(req.body.id, req.body.pw, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({
                    statusCode: 200
                });
            } else {
                res.status(401);
                res.json({
                    statusCode: 401,
                    msg: "패스워드 변경에 실패했습니다."
                });
                console.log(`updatePassword: ${err}`);
            }
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = updatePassword;