const Screen = require('../model/screen');

module.exports = {
    homePosters: function (req, res) {
        Screen.getHomePosters(function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(411)
                res.json({statusCode: 411, msg: "Failed to retrieve posters from DB"});
            }
        });
    },

    homeNotices: function (req, res) {
        Screen.getHomeNotices(function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({statusCode: 200, data: row});
            } else {
                res.status(411)
                res.json({statusCode: 411, msg: "Failed to retrieve notices from DB"});
            }
        });
    }
}