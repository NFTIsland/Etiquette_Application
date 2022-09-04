const mysql = require("mysql")
require("dotenv").config();

const mysqlConnection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    dateStrings: 'date',
    multipleStatements : true
});

mysqlConnection.connect((error) => {
    if (error) {
        console.log(error);
        return;
    } else {
        console.log('DB is connected');
    }
});

module.exports = mysqlConnection;