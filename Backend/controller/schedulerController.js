const Scheduler = require('../model/scheduler');

module.exports = {
    auctionSchedule: function (req, res) {
        const token_id = req.body.token_id;
        const alias = req.body.alias;
        const auction_end_date = req.body.auction_end_date;
        var statusCode = Scheduler.setSchedule(token_id, alias, auction_end_date);
        res.status(statusCode);
        res.sendStatus(statusCode);
    },
}