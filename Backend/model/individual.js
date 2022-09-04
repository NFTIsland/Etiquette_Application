const connection = require('../config/database.js');

module.exports = {
    getHoldlist: function (kas_address, callback) {
        const sql = "\
        SELECT token_id, product_name, category, performance_date, place, seat_class, seat_No \
        FROM user_db.tickets NATURAL JOIN user_db.ticket_description \
        WHERE owner = (?) \
        AND now() < performance_date \
        AND token_id NOT IN (SELECT token_id \
        FROM user_db.auction_tickets) \
        ORDER BY performance_date ASC;"
        connection.query(sql, [kas_address], callback);
    },

    getSellinglist: function (kas_address, callback) {
        const sql = "SELECT token_id, product_name, performance_date, place, seat_class, seat_No, auction_end_date \
        FROM user_db.auction_tickets NATURAL JOIN user_db.tickets \
        WHERE owner = (?) \
        AND now() < auction_end_date;"
        connection.query(sql, [kas_address], callback);
    },

    getUsedlist: function (kas_address, callback) {
        const sql = "\
        SELECT product_name, performance_date, place, seat_class, seat_No \
        FROM user_db.tickets \
        WHERE owner = (?) \
        AND now() > performance_date \
        ORDER BY performance_date DESC;"
        connection.query(sql, [kas_address], callback);
    },

    setInterestTicketing: function (product_name, place, kas_address, callback) {
        const sql = "\
        INSERT INTO user_db.interest_for_ticketing (`product_name`, `place`, `kas_address`) \
        VALUES ((?), (?), (?));";
        connection.query(sql, [product_name, place, kas_address], callback);
    },

    delInterestTicketing: function (product_name, place, kas_address, callback) {
        const sql = "\
        DELETE FROM user_db.interest_for_ticketing \
        WHERE product_name = (?) \
        AND place = (?) \
        AND kas_address = (?);";
        connection.query(sql, [product_name, place, kas_address], callback);
    },

    setInterestAuction: function (product_name, place, seat_class, seat_No, kas_address, callback) {
        const sql = "\
        INSERT INTO user_db.interest_for_auction (`product_name`, `place`, `seat_class`, `seat_No`, `kas_address`) \
        VALUES ((?), (?), (?), (?), (?));";
        connection.query(sql, [product_name, place, seat_class, seat_No, kas_address], callback);
    },

    delInterestAuction: function (product_name, place, seat_class, seat_No, kas_address, callback) {
        const sql = "\
        DELETE FROM user_db.interest_for_auction \
        WHERE product_name = (?) \
        AND place = (?) \
        AND seat_class = (?) \
        AND seat_No = (?) \
        AND kas_address = (?);";
        connection.query(sql, [product_name, place, seat_class, seat_No, kas_address], callback);
    },

    getInterestTicketing: function (kas_address, callback) {
        const sql = "\
        SELECT * \
        FROM user_db.interest_for_ticketing \
        WHERE kas_address = (?);";
        connection.query(sql, [kas_address], callback);
    },

    getInterestAuction: function (kas_address, callback) {
        const sql = "\
        SELECT token_id, T.product_name, T.owner, T.place, T.performance_date, T.seat_class, T.seat_No \
        FROM user_db.tickets T RIGHT JOIN user_db.interest_for_auction I \
        ON (T.product_name = I.product_name \
        AND T.place = I.place \
        AND T.seat_class = I.seat_class \
        AND T.seat_No = I.seat_No) \
        WHERE I.kas_address = (?);";
        connection.query(sql, [kas_address], callback);
    },

    getIsInterestedTicketing: function (product_name, place, kas_address, callback) {
        const sql = "\
        SELECT * \
        FROM user_db.interest_for_ticketing \
        WHERE product_name = (?) \
        AND place = (?) \
        AND kas_address = (?);";
        connection.query(sql, [product_name, place, kas_address], callback);
    },

    getIsInterestedAuction: function (product_name, place, seat_class, seat_No, kas_address, callback) {
        const sql = "\
        SELECT * \
        FROM user_db.interest_for_auction \
        WHERE product_name = (?) \
        AND place = (?) \
        AND seat_class = (?) \
        AND seat_No = (?) \
        AND kas_address = (?);";
        connection.query(sql, [product_name, place, seat_class, seat_No, kas_address], callback);
    },
}