const connection = require('../config/database.js');

module.exports = {
    getSearch: function (keyword, callback) {
        const sql = "\
        SELECT product_name, place \
        FROM user_db.tickets \
        WHERE owner IN (SELECT kas_address \
        FROM user_db.users \
        WHERE role = '2') \
        AND product_name LIKE (?) \
        GROUP BY product_name, place;";
        connection.query(sql, [`%${keyword}%`], callback);
    },

    getTicketInfo: function (callback) {
        const sql = "\
        SELECT product_name, place \
        FROM user_db.tickets \
        WHERE owner IN (SELECT kas_address \
        FROM user_db.users \
        WHERE role = '2') \
        GROUP BY product_name;";
        connection.query(sql, callback);
    },

    getTicketPriceInfo: function (product_name, callback) {
        connection.query("SELECT * FROM user_db.ticket_price WHERE product_name = (?)",[product_name], callback);
    },

    getTicketDescription: function (product_name, callback) {
        connection.query("SELECT * FROM user_db.ticket_description WHERE product_name = (?)", [product_name], callback);
    },

    getTicketPerformanceDate: function (product_name, place, callback) {
        const sql = "\
        SELECT DATE(performance_date) AS `date` \
        FROM (SELECT DISTINCT(performance_date) \
        FROM user_db.tickets \
        WHERE owner IN (SELECT kas_address \
        FROM user_db.users \
        WHERE role = '2') \
        AND product_name = (?) \
        AND place = (?) \
        ORDER BY performance_date ASC) AS `performance_date`;"
        connection.query(sql, [product_name, place], callback);
    },

    getTicketPerformanceTime: function (product_name, place, date, callback) {
        const sql = "\
        SELECT TIME(performance_date) AS `time` \
        FROM (SELECT DISTINCT(performance_date) \
        FROM user_db.tickets \
        WHERE owner IN (SELECT kas_address \
        FROM user_db.users \
        WHERE role = '2') \
        AND product_name = (?) \
        AND place = (?) \
        AND DATE(performance_date) = (?) \
        ORDER BY performance_date ASC) AS `performance_date`;"
        connection.query(sql, [product_name, place, date], callback);
    },

    getSeatClass: function (product_name, place, date, time, callback) {
        const datetime = date + " " + time;
        const sql = "\
        SELECT DISTINCT(seat_class) \
        FROM user_db.tickets \
        WHERE product_name = (?) \
        AND place = (?) \
        AND performance_date = (?);"
        connection.query(sql, [product_name, place, datetime], callback);
    },

    getSeatNo: function (product_name, place, date, time, seat_class, callback) {
        const datetime = date + " " + time;
        const sql = "\
        SELECT DISTINCT(seat_No) \
        FROM user_db.tickets \
        WHERE product_name = (?) \
        AND place = (?) \
        AND performance_date = (?) \
        AND seat_class = (?);"
        connection.query(sql, [product_name, place, datetime, seat_class], callback);
    },

    getPrice: function (product_name, seat_class, callback) {
        const sql = "\
        SELECT price \
        FROM user_db.ticket_price \
        WHERE product_name = (?) \
        AND seat_class = (?);"
        connection.query(sql, [product_name, seat_class], callback);
    },

    getTicketSeatImageUrl: function (product_name, place, callback) {
        const sql = "SELECT seat_image_url \
        FROM user_db.seat_image \
        WHERE product_name = (?) \
        AND place = (?);"
        connection.query(sql, [product_name, place], callback);
    },

    getTicketTokenIdAndOwner: function (product_name, place, date, time, seat_class, seat_No, callback) {
        const datetime = `${date} ${time}`;
        const sql = "\
        SELECT token_id, owner \
        FROM (SELECT token_id, owner \
        FROM user_db.tickets \
        WHERE product_name = (?) \
        AND place = (?) \
        AND performance_date = (?) \
        AND seat_class = (?) \
        AND seat_No = (?) as `owner` \
        WHERE owner IN (SELECT kas_address \
        FROM user_db.users \
        WHERE role = '2');"
        connection.query(sql, [product_name, place, datetime, seat_class, seat_No], callback);
    },

    setUpdateTicketOwner: function (owner, token_id, callback) {
        const sql = "\
        UPDATE user_db.tickets \
        SET owner = (?) \
        WHERE token_id = (?);";
        connection.query(sql, [owner, token_id], callback);
    },

    getOwner: function (token_id, callback) {
        const sql = "\
        SELECT owner \
        FROM user_db.tickets \
        where token_id = (?);";
        connection.query(sql, [token_id], callback);
    },

    getHotPick: function (callback) {
        const sql = "\
        SELECT product_name, place, count(*) as `count` \
        FROM user_db.interest_for_ticketing \
        GROUP BY product_name, place \
        ORDER BY `count` DESC, product_name ASC, place ASC \
        LIMIT 0, 5;";
        connection.query(sql, callback);
    },

    get5Deadline: function (callback) {
        const sql = "\
        SELECT product_name, place \
        FROM user_db.tickets \
        WHERE owner IN (SELECT kas_address \
        FROM user_db.users \
        WHERE role = '2') \
        AND now() < performance_date \
        AND now() >= DATE_SUB(performance_date, INTERVAL 1 DAY) \
        GROUP BY product_name, place \
        ORDER BY product_name ASC, place ASC \
        LIMIT 0, 5;";
        connection.query(sql, callback);
    },

    getAllDeadline: function (callback) {
        const sql = "\
        SELECT product_name, place \
        FROM user_db.tickets \
        WHERE owner IN (SELECT kas_address \
        FROM user_db.users \
        WHERE role = '2') \
        AND now() < performance_date \
        AND now() >= DATE_SUB(performance_date, INTERVAL 1 DAY) \
        GROUP BY product_name, place \
        ORDER BY product_name ASC, place ASC;";
        connection.query(sql, callback);
    },
}