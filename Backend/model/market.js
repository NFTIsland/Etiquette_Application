const connection = require('../config/database.js');

module.exports = {
    getSearch: function (keyword, callback) {
        const sql = "\
        SELECT T1.token_id, T1.product_name, T1.owner, T1.place, T1.performance_date, T1.seat_class, T1.seat_No, T2.poster_url \
        FROM (SELECT token_id, product_name, owner, place, performance_date, seat_class, seat_No \
        FROM user_db.auction_tickets NATURAL JOIN user_db.tickets \
        WHERE product_name LIKE (?) \
        AND now() < auction_end_date \
        ORDER BY seat_class DESC, seat_No ASC) T1 LEFT JOIN user_db.ticket_description T2 \
        ON (T1.product_name = T2.product_name);";
        connection.query(sql, [`%${keyword}%`], callback); // 2차 티켓 중 이름에 keyword가 들어간 티켓을 가져오기
    },

    getAuctionInfo: function (token_id, callback) {
        const sql = "\
        SELECT * \
        FROM user_db.auction_tickets \
        WHERE token_id = (?); \
        AND now() < auction_end_date;";
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
        SELECT T1.token_id, T1.product_name, T1.owner, T1.place, T1.performance_date, T1.seat_class, T1.seat_No, T1.bid_count, T2.poster_url \
        FROM (SELECT T.token_id, T.product_name, T.owner, T.place, T.performance_date, T.seat_class, T.seat_No, count(*) as `bid_count` \
        FROM user_db.auction A LEFT JOIN user_db.tickets T \
        ON (A.token_id = T.token_id) \
        GROUP BY A.token_id \
        ORDER BY `bid_count` DESC, product_name ASC, place ASC \
        LIMIT 0, 5) T1 LEFT JOIN user_db.ticket_description T2 \
        ON (T1.product_name = T2.product_name);";
        connection.query(sql, callback);
    },

    get5DeadlineAuction: function (callback) {
        const sql = "\
        SELECT T1.token_id, T1.product_name, T1.owner, T1.place, T1.seat_class, T1.seat_No, T1.auction_end_date, T2.poster_url \
        FROM (SELECT token_id, product_name, owner, place, seat_class, seat_No, auction_end_date \
        FROM user_db.auction_tickets NATURAL JOIN user_db.tickets \
        WHERE now() < auction_end_date \
        AND now() >= DATE_SUB(auction_end_date, INTERVAL 1 DAY) \
        GROUP BY product_name, place, token_id \
        ORDER BY product_name ASC, place ASC) T1 LEFT JOIN user_db.ticket_description T2 \
        ON (T1.product_name = T2.product_name) \
        LIMIT 0, 5;";
        connection.query(sql, callback);
    },

    getAllDeadlineAuction: function (callback) {
        const sql = "\
        SELECT T1.token_id, T1.product_name, T1.owner, T1.place, T1.seat_class, T1.seat_No, T1.auction_end_date, T2.poster_url \
        FROM (SELECT token_id, product_name, owner, place, seat_class, seat_No, auction_end_date \
        FROM user_db.auction_tickets NATURAL JOIN user_db.tickets \
        WHERE now() < auction_end_date \
        AND now() >= DATE_SUB(auction_end_date, INTERVAL 1 DAY) \
        GROUP BY product_name, place, token_id \
        ORDER BY product_name ASC, place ASC) T1 LEFT JOIN user_db.ticket_description T2 \
        ON (T1.product_name = T2.product_name)";
        connection.query(sql, callback);
    },

    delAuctionData: function (token_id, callback) {
        const sql1 = "DELETE FROM user_db.auction_tickets WHERE token_id = (?);";
        const sql2 = "DELETE FROM user_db.auction WHERE token_id = (?);";
        const sql = sql1 + sql2;
        connection.query(sql, [token_id, token_id], callback);
    }
}