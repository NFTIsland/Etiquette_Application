const Auth = require("../../model/auth");
require("dotenv").config();

const signup = async function (req, res) {
    try {
        Auth.selectLogIn_or_SignUp(req.body.id, function (err, row) {
            if (row != undefined && row.length) {
                res.status(409);
                res.json({
                    result: false,
                    msg: "해당 ID를 사용하는 계정이 이미 존재합니다."
                });
            } else {
                Auth.selectNickname(req.body.nickname, function (err, row) {
                    if (row != undefined && row.length) {
                        res.status(409);
                        res.json({
                            result: false,
                            msg: "이미 존재하는 닉네임 입니다."
                        });
                    } else {
                        Auth.selectKasAddress(req.body.kas_address, function (err, row) {
                            if (row != undefined && row.length) {
                                res.status(409);
                                res.json({
                                    result: false,
                                    msg: "이미 해당 클레이튼 주소를 사용하는 계정이 존재합니다. 다른 주소를 입력해 주세요."
                                });
                            } else {
                                Auth.insert(
                                req.body.id,
                                req.body.pw,
                                req.body.email,
                                req.body.nickname,
                                req.body.kas_address,
                                function (err, result) {
                                    if (err) throw err;
                                });
                                res.status(201);
                                res.json({
                                    result: true,
                                    msg: "회원가입이 성공적으로 진행되었습니다."
                                });
                            }
                        });
                    }
                })
            };
        })
    } catch (e) {
        console.error(e);
    }
}

module.exports = signup;