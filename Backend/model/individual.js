const connection = require('../config/database.js');

module.exports = {
    getMyEmail: function (id, callback) {
        const sql = "SELECT email FROM user_db.users where id = (?);"
        connection.query(sql, [id], callback);
    },

    getHoldlist: function (kas_address, callback) {
        const sql = "\
        SELECT token_id, product_name, category, performance_date, place, seat_class, seat_No, poster_url \
        FROM user_db.tickets NATURAL JOIN user_db.ticket_description \
        WHERE owner = (?) \
        AND now() < performance_date \
        AND token_id NOT IN (SELECT token_id \
        FROM user_db.auction_tickets) \
        ORDER BY performance_date ASC, product_name ASC;"
        connection.query(sql, [kas_address], callback);
    },

    getBidlist: function (kas_address, callback) {
        const sql = "\
        SELECT T1.token_id, T1.product_name, T1.owner, T1.place, T1.performance_date, T1.seat_class, T1.seat_No, T1.auction_end_date, T1.count, T1.max, T2.category, T2.poster_url \
        FROM (SELECT token_id, product_name, owner, place, performance_date, seat_class, seat_No, auction_end_date, count(bidder) as `count`, MAX(bid_price) as `max` \
        FROM user_db.auction NATURAL JOIN user_db.auction_tickets NATURAL JOIN user_db.tickets \
        WHERE token_id IN (SELECT DISTINCT(token_id) \
        FROM user_db.auction \
        WHERE bidder = (?)) \
        GROUP BY token_id) T1 LEFT JOIN user_db.ticket_description T2 \
        ON (T1.product_name = T2.product_name) \
        ORDER BY auction_end_date ASC, performance_date ASC;";
        connection.query(sql, [kas_address], callback);
    },


    getSellinglist: function (kas_address, callback) {
        const sql = "\
        SELECT T3.token_id, T3.product_name, T3.place, T3.seat_class, T3.performance_date, T3.auction_end_date, T3.seat_No, T3.count, T3.max, T4.poster_url \
        FROM (SELECT T1.token_id, T2.product_name, T2.place, T2.seat_class, T2.performance_date, T1.auction_end_date, T2.seat_No, T1.count, T1.max \
        FROM (SELECT S1.token_id, S1.auction_end_date, count(bidder) as `count`, MAX(bid_price) as `max` \
        FROM (SELECT DISTINCT(token_id), auction_end_date \
        FROM user_db.auction_tickets NATURAL JOIN user_db.tickets \
        WHERE owner = (?) \
        AND now() < auction_end_date) S1 LEFT JOIN user_db.auction S2 \
        ON (S1.token_id = S2.token_id) \
        GROUP BY token_id) T1 LEFT JOIN user_db.tickets T2 \
        ON (T1.token_id = T2.token_id)) T3 LEFT JOIN user_db.ticket_description T4 \
        ON (T3.product_name = T4.product_name) \
        ORDER BY T3.auction_end_date ASC;";
        connection.query(sql, [kas_address], callback);
    },


    getUsedlist: function (kas_address, callback) {
        const sql = "\
        SELECT T1.product_name, T1.performance_date, T1.place, T1.seat_class, T1.seat_No, T2.poster_url \
        FROM (SELECT product_name, performance_date, place, seat_class, seat_No \
        FROM user_db.tickets \
        WHERE owner = (?) \
        AND now() > performance_date \
        ORDER BY performance_date DESC) T1 LEFT JOIN user_db.ticket_description T2 \
        ON (T1.product_name = T2.product_name) \
        ORDER BY T1.performance_date ASC;";
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
        SELECT T.product_name, place, category, poster_url \
        FROM user_db.interest_for_ticketing I LEFT JOIN user_db.ticket_description T \
        ON (I.product_name = T.product_name) \
        WHERE kas_address = (?);";
        connection.query(sql, [kas_address], callback);
    },

    getInterestAuction: function (kas_address, callback) {
        const sql = "\
        SELECT T1.token_id, T1.product_name, T1.owner, T1.place, T1.performance_date, T1.seat_class, T1.seat_No, T2.category, T2.poster_url \
        FROM (SELECT token_id, T.product_name, T.owner, T.place, T.performance_date, T.seat_class, T.seat_No \
        FROM user_db.tickets T RIGHT JOIN user_db.interest_for_auction I \
        ON (T.product_name = I.product_name \
        AND T.place = I.place \
        AND T.seat_class = I.seat_class \
        AND T.seat_No = I.seat_No) \
        WHERE I.kas_address = (?)) T1 LEFT JOIN user_db.ticket_description T2 \
        ON (T1.product_name = T2.product_name);"
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
    
    getNumberOfHoldingTickets: function (kas_address, callback) {
        const sql = "\
        select count(*) as counts \
        from user_db.tickets \
        where owner = (?) \
        and now() < performance_date;";
        connection.query(sql, [kas_address], callback);
    },

    getNumberOfAuctionTickets: function (kas_address, callback) {
        const sql = "\
        SELECT count(distinct(token_id)) as counts \
        FROM user_db.auction \
        where bidder = (?);";
        connection.query(sql, [kas_address], callback);
    },
}