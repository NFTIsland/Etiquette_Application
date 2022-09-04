const Auth = require("../model/auth");
require("dotenv").config();
const KEY = process.env.DEV_KEY;
var jwt = require('jsonwebtoken');

module.exports = {
    login: function (req, res) {
        Auth.selectLogIn(req.body.id, req.body.pw, function (err, row) {
            if (row != undefined && row.length) {
                var payload = {
                    id: req.body.id,
                };
                var token = jwt.sign(payload, KEY, { algorithm: 'HS256', expiresIn: "1h" });
                res.send(token);
            } else {
                res.status(401)
                res.send("There's no user matching that");
            }
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
        Auth.selectSignUp(req.body.id, req.body.pw, function (err, row) {
            if (row != undefined && row.length) {
                res.status(409);                
                res.json({result: false, msg: "An user with that id already exists"});
            } else {
                Auth.selectNickname(req.body.nickname, function (err, row) {
                    if (row != undefined && row.length) {
                        res.status(409);
                        res.json({result: false, msg: "An user with that nickname already exists"});
                    } else {
                        Auth.insert(req.body.id, req.body.pw, req.body.nickname, function (err, result) {
                            if (err) throw err;
                        });
                        res.status(201);                        
                        res.json({result: true, msg: "Success"});
                    }
                })
            };
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

    kasAddress: function(req, res) {
        Auth.getKasAddress(req.body.id, function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(404)
                res.json({statusCode: 404, msg: "Failed to retrieve kas address from DB"});
            }
        })
    },
};