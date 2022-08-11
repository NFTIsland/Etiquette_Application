var crypto = require('crypto');
const connection = require('../config/database.js');

module.exports = {
    selectLogIn: function (id, pw, callback) {
        var cryptPassword = crypto.createHash('sha256').update(pw).digest('hex');
        connection.query("SELECT * FROM user_db.users WHERE id = ? AND pw = ?;", [id, cryptPassword], callback);
    },
    selectSignUp: function (id, pw, callback) {
        connection.query("SELECT * FROM users WHERE id = (?);", [id], callback);
    },
    insert: function (id, pw, nickname, kas_address, callback) {
        var cryptPassword = crypto.createHash('sha256').update(pw).digest('hex');
        connection.query("INSERT INTO user_db.users (id, pw, nickname, kas_address) VALUES (?, ?, ?, ?);", [id, cryptPassword, nickname, kas_address], callback);
    },
    selectNickname: function (nickname, callback) {
        connection.query("SELECT * FROM users WHERE nickname = (?);", [nickname], callback);
    }
};
