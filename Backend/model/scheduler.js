const request = require('request');
const schedule = require('node-schedule');
const caver = require('caver-js');
const BasicAuthDio = require('../model/kasBasicAuthDio');
const connection = require('../config/database.js');

const getCurrency = function () {
    return new Promise((resolve, reject) => {
        request.get({
            uri: "https://api.coinone.co.kr/public/v2/ticker_new/KRW/KLAY",
        }, function (err, res, body) {
            const data = JSON.parse(body);
            if (data["result"] === "success") {
                resolve(data["tickers"][0]["last"]);
            } else {
                console.log(err);
                reject(err);
            }
        });
    });
}

const sql_owner = "\
SELECT DISTINCT(owner) \
FROM user_db.auction NATURAL JOIN user_db.tickets \
WHERE token_id = (?);";

const getOwner = function (token_id) {
    return new Promise((resolve, reject) => {
        connection.query(sql_owner, [token_id], function (err, res) {
            if (!err) {
                resolve(res[0]['owner']);
            } else {
                reject(err);
            }
        });
    });
}

const sql_auction = "\
SELECT bidder, bid_price \
FROM user_db.auction \
WHERE token_id = (?) \
ORDER BY bid_price DESC, bid_date ASC;";

const getAuctionHistory = function (token_id) {
    return new Promise((resolve, reject) => {
        connection.query(sql_auction, [token_id], function (err, res) {
            if (!err) {
                resolve(res);
            } else {
                reject(err);
            }
        });
    });
}

const klayTransaction = function (bidder, bid_price, klayCurrency, owner) {
    return new Promise((resolve, reject) => {
        const peb = caver.utils.convertToPeb((bid_price / klayCurrency).toString(), 'KLAY'); // KLAY를 Peb으로 환산
        const hexpeb = caver.utils.numberToHex(peb);
        const options_klayTransaction = new BasicAuthDio('POST', 'https://wallet-api.klaytnapi.com/v2/tx/value', {
            "from": bidder,
            "value": hexpeb,
            "to": owner,
            "submit": true
        });

        request.post(options_klayTransaction, function (err, res, body) {
            if (res.statusCode == 200) {
                resolve();
            } else {
                reject(body['message']);
            }
        });
    });
}

const transaction = async (auctionHistory, klayCurrency, owner) => {
    var isTransactionComplete = false;
    var _bidder = "";
    for (const data of auctionHistory) {
        if (!isTransactionComplete) {
            const bidder = data.bidder;
            const bid_price = parseInt(data.bid_price);
            await klayTransaction(bidder, bid_price, klayCurrency, owner)
            .then(() => {
                isTransactionComplete = true;
                _bidder = bidder;
                console.log(`${bidder} -> ${owner} klay transaction complete!(${bid_price} won)`);
            }).catch((msg) => {
                console.log(`klayTransaction -> ${msg}`);
            })
        } else {
            break;
        }
    }
    return _bidder;
}

const tokenTransfer = function (alias, token_id, owner, bidder) {
    return new Promise((resolve, reject) => {
        const options_tokenTransfer = new BasicAuthDio('POST', `https://kip17-api.klaytnapi.com/v2/contract/${alias}/token/${token_id}`, {
            "sender": owner,
            "owner": owner,
            "to": bidder,
        });

        request.post(options_tokenTransfer, function (err, res, body) {
            if (res.statusCode == 200) {
                resolve();
            } else {
                reject(body);
            }
        });
    });
}

const sql_terminate_auction = "\
DELETE FROM `user_db`.`auction` \
WHERE token_id = (?);  \
DELETE FROM `user_db`.`auction_tickets` \
WHERE token_id = (?); \
UPDATE `user_db`.`tickets` \
SET owner = (?) \
WHERE token_id = (?);";

const terminateAuction = function (token_id, bidder) {
    return new Promise((resolve, reject) => {
        connection.query(sql_terminate_auction, [token_id, token_id, bidder, token_id], function (err, res) {
            if (!err) {
                resolve();
            } else {
                reject(err);
            }
        });
    });
}

const sql_end_of_auction = "\
SELECT token_id, category \
FROM user_db.tickets NATURAL JOIN user_db.ticket_description \
WHERE token_id IN (SELECT token_id \
FROM user_db.auction_tickets \
WHERE now() > auction_end_date);";

const getAuctionEnd = function () {
    return new Promise((resolve, reject) => {
        connection.query(sql_end_of_auction, function (err, res) {
            if (!err) {
                resolve(res);
            } else {
                reject(err);
            }
        });
    });
}

module.exports = {
    setSchedule: function (token_id, alias, auction_end_date) {
        try {
            const year = parseInt(auction_end_date.substring(0, 4));
            const month = parseInt(auction_end_date.substring(5, 7)) - 1;
            const day = parseInt(auction_end_date.substring(8, 10));
            const hour = parseInt(auction_end_date.substring(11, 13));
            const minute = parseInt(auction_end_date.substring(14, 16));
            const date = new Date(year, month, day, hour, minute, 0);

            const job = function () {
                schedule.scheduleJob(date, async function () {
                    getCurrency()
                    .then((klayCurrency) => {
                        const _klayCurrency = klayCurrency;
                        console.log(`klayCurrency: ${_klayCurrency}`);
                        
                        getOwner(token_id)
                        .then((owner) => {
                            const _owner = owner;
                            console.log(`owner: ${_owner}`);

                            getAuctionHistory(token_id)
                            .then(async (auctionHistory) => {
                                console.log(`<${token_id} -> ${_owner}>`);
                                for (var idx = 0; idx < auctionHistory.length; idx++) {
                                    console.log(auctionHistory[idx].bidder, auctionHistory[idx].bid_price);
                                }

                                const bidder = await transaction(auctionHistory, klayCurrency, _owner);
                                console.log(`bidder -> ${bidder}`);

                                tokenTransfer(alias, token_id, _owner, bidder)
                                .then(() => {
                                    terminateAuction(token_id, bidder)
                                    .then(() => {
                                        console.log("finished");
                                    }).catch((body) => {
                                        console.log(`terminateAuction -> ${body}`);
                                    })
                                }).catch((body) => {
                                    console.log(`token transfer -> ${body}`);
                                })
                            }).catch((err) => {
                                console.log(`getAuctionHistory -> ${err}`);
                            })
                        }).catch((err) => {
                            console.log(`getOwner -> ${err}`);
                        })
                    }).catch((err) => {
                        console.log(`getCurrency -> ${err}`);
                    })
                });
            }
    
            job();
            return 200;
        } catch (e) {
            console.log(e);
            return 401;
        }
    },

    checkAuctionEnd: function () {
        try {
            schedule.scheduleJob('0 * * * * *', async function () {
                console.log(`check auction end tickets at ${new Date(Date.now()).toString()}`);
                getCurrency()
                .then((klayCurrency) => {
                    const _klayCurrency = klayCurrency;
                    getAuctionEnd()
                    .then((res) => {
                        if (res.length > 0) {
                            for (var idx = 0; idx < res.length; idx++) {
                                const token_id = res[idx].token_id;
                                const alias = res[idx].category;
                                getOwner(token_id)
                                .then((owner) => {
                                    const _owner = owner;
                                    getAuctionHistory(token_id)
                                    .then(async (auctionHistory) => {
                                        console.log(`<${token_id} -> ${_owner}>`);
                                        for (var idx = 0; idx < auctionHistory.length; idx++) {
                                            console.log(auctionHistory[idx].bidder, auctionHistory[idx].bid_price);
                                        }
                
                                        const bidder = await transaction(auctionHistory, _klayCurrency, _owner);
                                        console.log(`bidder -> ${bidder}`);
                
                                        tokenTransfer(alias, token_id, _owner, bidder)
                                        .then(() => {
                                            terminateAuction(token_id, bidder)
                                            .then(() => {
                                                console.log(`Token ID ${token_id} finished`);
                                            }).catch((err) => {
                                                console.log(`terminateAuction -> ${err}`);
                                            })
                                        }).catch((msg) => {
                                            console.log(`token transfer -> ${msg}`);
                                        })
                                    }).catch((err) => {
                                        console.log(`getAuctionHistory -> ${err}`);
                                    })
                                }).catch((err) => {
                                    console.log(`getOwner -> ${err}`);
                                })
                            }
                        }
                    }).catch((err) => {
                        console.log(`getAuctionEnd -> ${err}`);
                    })
                }).catch((err) => {
                    console.log(`getCurrency -> ${err}`);
                })
            });
        } catch (e) {
            console.log(`checkAuctionEnd -> ${e}`);
        }
    }
}