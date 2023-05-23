const bcrypt = require('bcrypt');
const Auth = require("../../model/auth");

const checkPassword = async function (req, res) {
    await Auth.selectLogIn(req.body.id, req.body.pw, async (err, row) => {
        if (!err) {
            const hashed_PW = row[0]['pw'];
            const isValid = await bcrypt.compare(req.body.pw, hashed_PW);
            if (isValid) {
                res.status(200);
                res.json({
                    statusCode: 200
                });
            } else {
                res.status(401);
                res.send("비밀번호가 일치하지 않습니다.");
            }
        } else {
            res.status(401);
            res.send("비밀번호가 일치하지 않습니다.");
        }
    });
}

module.exports = checkPassword;