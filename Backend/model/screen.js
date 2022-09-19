const connection = require('../config/database.js');

module.exports = {
    getHomePosters: function (callback) {
        const sql = "\
        SELECT DISTINCT(poster_url) \
        FROM user_db.main_page_posters;";
        connection.query(sql, callback);
    },

    getHomeNotices: function (callback) {
        const sql = "\
        SELECT title, contents, upload_time \
        FROM user_db.notice \
        ORDER BY upload_time DESC \
        LIMIT 0, 5;";
        connection.query(sql, callback);
    }
}