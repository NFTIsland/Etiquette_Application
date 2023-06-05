const wallet = require('../../../service/kas/wallet');

const transactionHistory = async function (req, res) {
    try {
        const address = req.body.address; // 트랜잭션 내역을 조회할 클레이튼 주소
        const type = req.body.type;
        // 조회할 트랜잭션 유형 (여기에서는 "ticket_buy", "ticket_sell", "klay_deposit", "klay_withdraw", "all" 중 하나로 설정) 
        const period = req.body.period; // 조회기간 (여기에서는 1w, 1m, 3m 중 하나로 설정)
        const history = await wallet.kasTransactionHistory(address, type, period);

        if (history['statusCode'] == 200) {
            res.status(200);
            var items = [];
            var size = history['data']['items'].length;
            for (var i = 0; i < size; i++) {
                var temp = history['data']['items'][i];
                var value = (temp["value"] == undefined) ? "0x0" : temp["value"];

                if (temp["transferType"] === "klay") {
                    items.push({
                        "transferType": "klay",
                        "from": temp["from"],
                        "to": temp["to"],
                        "timestamp": temp["timestamp"],
                        "value": value
                    });
                } else if (temp["transferType"] === "nft") {
                    items.push({
                        "transferType": "nft",
                        "from": temp["from"],
                        "to": temp["to"],
                        "timestamp": temp["transaction"]["timestamp"],
                        "tokenId": temp["tokenId"],
                        "value": value
                    });
                }
            }
            res.json({
                statusCode: 200,
                data: items
            });
        } else {
            res.status(401);
            res.json({
                statusCode: 401,
                msg: "거래 내역을 불러오는데 실패했습니다. 잠시 후 다시 시도해주세요."
            });
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = transactionHistory;