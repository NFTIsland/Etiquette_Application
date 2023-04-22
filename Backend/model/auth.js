const bcrypt = require('bcrypt'); // 정보 암호화를 위한 bcrypt 모듈
const connection = require('../config/database.js');

module.exports = {
    // 회원가입 혹은 로그인 시, 사용자가 입력한 ID에 부합하는 정보 확인
    selectLogIn_or_SignUp: function (id, callback) {
        connection.query("SELECT * FROM user_db.users WHERE id = ?;", [id], callback);
    },

    // 사용자 정보 새로 추가
    insert: async function (id, pw, email, nickname, kas_address, callback) {
        const hashed_PW = await bcrypt.hash(pw, 10);
        connection.query("INSERT INTO user_db.users (id, pw, email, nickname, kas_address, role) VALUES (?, ?, ?, ?, ?, ?);", [id, hashed_PW, email, nickname, kas_address, '1'], callback);
    },

    // 사용자 정보 수정
    updatePW: async function (id, pw, callback) {
        const hashed_PW = await bcrypt.hash(pw, 10);
        connection.query("UPDATE user_db.users SET pw = ? WHERE id = ?;", [hashed_PW, id], callback);
    },

    // 닉네임 수정하기
    updateNickName: function (id, nickname, callback) {
        connection.query("UPDATE user_db.users SET nickname = ? WHERE id = ?;", [nickname, id], callback);
    },

    // 닉네임이 이미 존재하는지 확인
    selectNickname: function (nickname, callback) {
        connection.query("SELECT * FROM user_db.users WHERE nickname = (?);", [nickname], callback);
    },
    
    // 입력된 ID로 KAS 주소 얻어오기
    getKasAddress: function (id, callback) {
        const sql = "SELECT kas_address \
        FROM user_db.users \
        WHERE id = (?);"
        connection.query(sql, [id], callback);
    },

    // 해당 KAS 주소가 있는지 확인
    selectKasAddress: function (kas_address, callback) {
        const sql = "SELECT * FROM user_db.users WHERE kas_address = (?);";
        connection.query(sql, [kas_address], callback);
    }
};