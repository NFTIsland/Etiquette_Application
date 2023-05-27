const caver = require('caver-js');
const schedule = require('node-schedule');
const Scheduler = require("../../model/scheduler");
const coinone = require("../../service/scheduler/coinone");
const wallet = require("../../service/kas/wallet");
const kip17 = require("../../service/kas/kip17");
const Ticket = require("../../model/ticket");

const transaction = async (auctionHistory, klayCurrency, owner) => {
    try {
        for (const data of auctionHistory) {
            const bidder = data.bidder;
            const bid_price = parseInt(data.bid_price);
            const peb = caver.utils.convertToPeb((bid_price / klayCurrency).toString(), 'KLAY');
            const hexpeb = caver.utils.numberToHex(peb);

            const transaction = await wallet.kasKlayTransaction(bidder, hexpeb, owner);
            if (transaction['statusCode'] == 200) {
                isTransactionComplete = true;
                console.log(`${bidder} -> ${owner} klay transaction complete!(${bid_price} won)`);
                return bidder;
            } else {
                console.log(`klayTransaction -> ${transaction['data']['message']}`);
            }
        }
        return "none";
    } catch (e) {
        console.error(`transaction -> ${e}`);
    }
}

const traverseAuctionEnd = async function (req, res) {
    try {
        schedule.scheduleJob('0 * * * * *', async function () {
            console.log(`check auction end tickets at ${new Date(Date.now()).toString()}`);
            var klayCurrencyData = await coinone.getCurrency(); 
            klayCurrencyData = klayCurrencyData["data"];
            if (klayCurrencyData["result"] === "success") {
                const klayCurrency = klayCurrencyData["tickers"][0]["last"];
                console.log(`klayCurrency -> ${klayCurrency}`);

                Scheduler.getEndOfAuction(function (err, row) {
                    if (row != undefined && row.length) {
                        for (var idx = 0; idx < row.length; idx++) {
                            const token_id = row[idx].token_id;
                            const alias = row[idx].category;

                            Scheduler.getOwner(token_id, function (err, row) {
                                if (row != undefined && row.length) {
                                    const owner = row[0]['owner'];

                                    Scheduler.getAuctionHistory(token_id, async function (err, row) {
                                        if (row != undefined && row.length) {
                                            console.log(`<token_id: ${token_id}, owner: ${owner}>`);
                                            for (var idx = 0; idx < row.length; idx++) {
                                                console.log(row[idx].bidder, row[idx].bid_price);
                                            }

                                            const bidder = await transaction(row, klayCurrency, owner);
                                            console.log(`bidder -> ${bidder}`);

                                            if (bidder === "none" || bidder === undefined) {
                                                console.log("낙찰자가 없습니다.");
                                            } else {
                                                const tokenTransfer = await kip17.kasKip17TokenTransfer(alias, token_id, owner, owner, bidder);
                                                if (tokenTransfer['statusCode'] == 200) {
                                                    console.log(`${owner} -> ${bidder} NFT 전송`);

                                                    Ticket.setUpdateTicketOwner(bidder, token_id, function (err, row) {
                                                        if (err) {
                                                            console.log(`setUpdateTicketOwner -> ${err}`);
                                                        }
                                                    });
                                                } else {
                                                    console.log(`tokenTransfer -> ${tokenTransfer['data']['message']}`);
                                                }
                                            }
                                            Scheduler.delAuctionTicket(token_id, function (err, row) {
                                                if (!err) {
                                                    console.log(`token_id ${token_id} 티켓에 대한 경매 마감 처리 완료`);
                                                } else {
                                                    console.log(`delAuctionTicket -> ${err}`);
                                                }
                                            });

                                        }
                                    });
                                } else {
                                    console.log(`getOwner -> ${err}`);
                                }
                            });
                        }
                    } else if (row.length == 0) {
                        console.log("마감된 경매 티켓이 없습니다.");
                    } else {
                        console.log(`getEndOfAuction -> ${err}`);
                    }
                });
            } else {
                console.log(`getCurrency -> ${klayCurrencyData["data"]["error_msg"]}`);
            }
        });
    } catch (e) {
        console.error(e);
    }
}

module.exports = traverseAuctionEnd;