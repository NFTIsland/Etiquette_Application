const Auth = require("../model/auth");
require("dotenv").config();
const KEY = process.env.DEV_KEY;
var jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');

module.exports = {
    login: function (req, res) {
        Auth.selectLogIn(req.body.id, req.body.pw, function (err, row) {
            if (row != undefined && row.length) {
                var getToken = () => {
                    return new Promise((resolve, reject) => {
                        var payload = {
                            id: req.body.id,
                        };
                        jwt.sign(payload, KEY, { algorithm: 'HS256', expiresIn: "1h" }, 
                        function(err, token){
                            if (err){
                                reject(err);
                            }
                            else{
                                resolve(token);
                            }
                        })
                    });
                }
                getToken().then(token => {res.json({token: token, nickname: row[0]["nickname"]});})
            } else {
                res.status(401);
                res.send("There's no user matching that");
            }
        })
    },

    sendRandomPW: function(req, res) {
        var sendRandomPWEmail = () => {
            return new Promise((resolve, reject) =>{
                var variable = "0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z".split(",");
                var randomPassword = createRandomPW(variable, 8);

                function createRandomPW(variable, passwordLength) {
                    var randomString = "";
                    for (var i = 0; i < passwordLength; i++)
                        randomString += variable[Math.floor(Math.random()*variable.length)];
                        return randomString
                }

                const transporter = nodemailer.createTransport({
                    service: 'gmail',
                    port: 465,
                    secure: true,
                    auth: {
                        user: process.env.NODEMAILER_USER,
                        pass: process.env.NODEMAILER_PASS,
                    },
                });

                const emailOptions = {
                    rom: process.env.NODEMAILER_USER,
                    to: req.body.email,
                    subject: 'Etiquette 임시 비밀번호 알림',
                    html:
                    "<h1>Etiquette에서 새로운 비밀번호를 알려드립니다.</h1> <h2> 비밀번호 : " + randomPassword + "</h2>"
                    +'<h3 style="color: crimson;">임시 비밀번호로 로그인 하신 후, 반드시 비밀번호를 변경해 주십시오.</h3>'
                };

                transporter.sendMail(emailOptions, function (error, info) {
                    if (error) {
                        reject(new Error("Request is failed"));
                    } else {
                        var sent = [true, req.body.id, randomPassword];
                        resolve(sent);
                    }
                });
            });
        }

        sendRandomPWEmail().then (sent => {
            Auth.updatePW(sent.at(1), sent.at(2), function (err, row) {
                if (!err) {
                    res.status(200);
                    res.json({statusCode: 200});
                } else {
                    res.status(401);
                    res.json({statusCode: 401, msg: "Failed to update PW"});
                    console.log(`sendRandomPW - updatePassword: ${err}`);
                }
            })}).catch(function() {
                res.status(401);
                res.json({msg: "Cannot Send Email."});
            })
    },   

    home: function (req, res) {
        var str = req.get('Authorization');
        try {
            jwt.verify(str, KEY, { algorithm: 'HS256' });
            res.send("Welcome");
        } catch {
            res.status(401);
            res.send("Bad Token");
        }
    },

    signup: function(req, res) {
        Auth.selectSignUp(req.body.id, function (err, row) {
            if (row != undefined && row.length) {
                res.status(409);                
                res.json({result: false, msg: "An user with that id already exists"});
            } else {
                Auth.selectNickname(req.body.nickname, function (err, row) {
                    if (row != undefined && row.length) {
                        res.status(409);
                        res.json({result: false, msg: "An user with that nickname already exists"});
                    } else {
                        Auth.insert(req.body.id, req.body.pw, req.body.email, req.body.nickname, req.body.kas_address, function (err, result) {
                            if (err) throw err;
                        });
                        res.status(201);                        
                        res.json({result: true, msg: "Success"});
                    }
                })
            };
        })
    },

    updatePassword: function (req, res) {
        Auth.updatePW(req.body.id, req.body.pw, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({statusCode: 200});
            } else {
                res.status(401);
                res.json({statusCode: 401, msg: "Failed to update PW"});
                console.log(`updatePassword: ${err}`);
            }
        })
    },

    updateNickname: function (req, res) {
        Auth.updateNickName(req.body.id, req.body.nickname, function (err, row) {
            if (!err) {
                res.status(200);
                res.json({statusCode: 200});
            } else {
                res.status(401);
                res.json({statusCode: 401, msg: "Failed to update Nickname"});
                console.log(`updateNickname: ${err}`);
            }
        })
    },

    checkNickname: function(req, res) {
        Auth.selectNickname(req.body.nickname, function (err, row) {
            if (row != undefined && row.length) {
                res.status(409);
                res.json({statusCode: 409, msg: "이미 존재하는 닉네임입니다."});
            } else {
                res.status(200);
                res.json({statusCode: 200, msg: "사용할 수 있는 닉네임입니다."});
            }
        });
    },

    checkPassword: function (req, res) {
        Auth.selectLogIn(req.body.id, req.body.pw, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200});
            } else {
                res.status(401);
                res.send("There's no user matching that");
            }
        })
    },

    kasAddress: function(req, res) {
        Auth.getKasAddress(req.body.id, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(404);
                res.json({statusCode: 404, msg: "Failed to retrieve kas address from DB"});
            }
        })
    },
};