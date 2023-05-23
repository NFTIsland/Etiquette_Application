const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const Auth = require("../../model/auth");
require("dotenv").config();
const KEY = process.env.DEV_KEY;

const login = async function (req, res) {
    await Auth.selectLogIn_or_SignUp(req.body.id, async (err, row) => {
    if (!err) {
        const hashed_PW = row[0]['pw'];
        const isValid = await bcrypt.compare(req.body.pw, hashed_PW);
        if (isValid) {
            var getToken = () => {
                return new Promise((resolve, reject) => {
                    var payload = {
                        id: req.body.id,
                    };
                    jwt.sign(payload, KEY, {
                            algorithm: 'HS256',
                            expiresIn: "1h"
                        },
                        function (err, token) {
                            if (err) {
                                reject(err);
                            } else {
                                resolve(token);
                            }
                        })
                    });
                }
                getToken().then(token => {
                    res.json({
                        token: token,
                        nickname: row[0]["nickname"]
                    })
                });
            } else {
                res.status(401);
                res.send("아이디 또는 비밀번호가 일치하지 않습니다.");
            }
        } else {
            res.status(401);
            res.send("아이디 또는 비밀번호가 일치하지 않습니다.");
        }
    });
}

module.exports = login;