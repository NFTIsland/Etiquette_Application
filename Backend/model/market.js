const connection = require('../config/database.js');

module.exports = {
    getSearch: function (keyword, callback) {
        const sql = "\
        SELECT token_id, product_name, owner, place, performance_date, seat_class, seat_No \
        FROM user_db.auction_tickets NATURAL JOIN user_db.tickets \
        WHERE product_name LIKE (?) \
        AND now() < auction_end_date;";
        connection.query(sql, [`%${keyword}%`], callback);
    },

    getAuctionInfo: function (token_id, callback) {
        const sql = "\
        SELECT * \
        FROM user_db.auction_tickets \
        WHERE token_id = (?);";
        connection.query(sql, [token_id], callback);
    },

    uploadTicketToBid: function (token_id, auction_start_price, bid_unit, immediate_purchase_price, auction_end_date, auction_comments, callback) {
        const sql = "\
        INSERT INTO user_db.auction_tickets(`token_id`, `auction_start_price`, `bid_unit`, `immediate_purchase_price`, `auction_start_date`, `auction_end_date`, `auction_comments`) \
        VALUES ((?), (?), (?), (?), now(), (?), (?));"
        connection.query(sql, [token_id, auction_start_price, bid_unit, immediate_purchase_price, auction_end_date, auction_comments], callback);
    },

    doBid: function (token_id, bidder, bid_price, callback) {
        const sql = "\
        INSERT INTO user_db.auction (`token_id`, `bidder`, `bid_date`, `bid_price`) \
        VALUES ((?), (?), now(), (?));";
        connection.query(sql, [token_id, bidder, bid_price], callback);
    },

    getBidStatus: function (token_id, callback) {
        const sql = "\
        SELECT nickname, bid_date, bid_price \
        FROM user_db.auction JOIN user_db.users \
        ON (user_db.auction.bidder = user_db.users.kas_address) \
        WHERE token_id = (?) \
        ORDER BY bid_price DESC, bid_date ASC;";
        connection.query(sql, [token_id], callback);
    },

    getBidStatusTop5: function (token_id, callback) {
        const sql = "\
        SELECT nickname, bid_date, bid_price \
        FROM user_db.auction JOIN user_db.users \
        ON (user_db.auction.bidder = user_db.users.kas_address) \
        WHERE token_id = (?) \
        ORDER BY bid_price DESC, bid_date ASC \
        LIMIT 0, 5;";
        connection.query(sql, [token_id], callback);
    },

    getTop5RankBid: function (callback) {
        const sql = "\
        SELECT T.token_id, T.product_name, T.owner, T.place, T.performance_date, T.seat_class, T.seat_No, count(*) as `bid_count` \
        FROM user_db.auction A LEFT JOIN user_db.tickets T \
        ON (A.token_id = T.token_id) \
        GROUP BY A.token_id \
        ORDER BY `bid_count` DESC, product_name ASC, place ASC \
        LIMIT 0, 5;";
        connection.query(sql, callback);
    },

    get5DeadlineAuction: function (callback) {
        const sql = "\
        SELECT product_name, place, seat_class, seat_No \
        FROM user_db.auction_tickets NATURAL JOIN user_db.tickets \
        WHERE now() < auction_end_date \
        AND now() >= DATE_SUB(auction_end_date, INTERVAL 1 DAY) \
        GROUP BY product_name, place \
        ORDER BY product_name ASC, place ASC \
        LIMIT 0, 5;";
        connection.query(sql, callback);
    },

    getAllDeadlineAuction: function (callback) {
        const sql = "\
        SELECT product_name, place, seat_class, seat_No \
        FROM user_db.auction_tickets NATURAL JOIN user_db.tickets \
        WHERE now() < auction_end_date \
        AND now() >= DATE_SUB(auction_end_date, INTERVAL 1 DAY) \
        GROUP BY product_name, place \
        ORDER BY product_name ASC, place ASC";
        connection.query(sql, callback);
    },

    delAuctionData: function (token_id, callback) {
        const sql1 = "DELETE FROM user_db.auction_tickets WHERE token_id = (?);";
        const sql2 = "DELETE FROM user_db.auction WHERE token_id = (?);";
        const sql = sql1 + sql2;
        connection.query(sql, [token_id, token_id], callback);
    }
}