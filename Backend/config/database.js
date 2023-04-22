const mysql = require("mysql2")
require("dotenv").config();

// DB 커넥션 객체 생성
const mysqlConnection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    dateStrings: 'date',
    multipleStatements : true
});

// DB 연결 성공 여부에 따라 로그 출력
mysqlConnection.connect((error) => {
    if (error) {
        console.log(error);
        return;
    } else {
        console.log('DB가 연결되었습니다.');
    }
});

module.exports = mysqlConnection;