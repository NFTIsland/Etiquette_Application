const connection = require('../config/database.js');

module.exports = {
    getEndOfAuction: function (callback) {
        const sql = "\
        SELECT token_id, category \
        FROM user_db.tickets NATURAL JOIN user_db.ticket_description \
        WHERE token_id IN (SELECT token_id \
        FROM user_db.auction_tickets \
        WHERE now() > auction_end_date);";
        connection.query(sql, callback);
    },

    getOwner: function (token_id, callback) {
        const sql = "\
        SELECT DISTINCT(owner) \
        FROM user_db.auction NATURAL JOIN user_db.tickets \
        WHERE token_id = (?);";
        connection.query(sql, [token_id], callback);
    },

    getAuctionHistory: function (token_id, callback) {
        const sql = "\
        SELECT bidder, bid_price \
        FROM user_db.auction \
        WHERE token_id = (?) \
        ORDER BY bid_price DESC, bid_date ASC;";
        connection.query(sql, [token_id], callback);
    },

    delAuctionTicket: function (token_id, callback) {
        const sql = "\
        DELETE FROM user_db.auction_tickets \
        WHERE token_id = (?);";
        connection.query(sql, [token_id], callback);
    },
}