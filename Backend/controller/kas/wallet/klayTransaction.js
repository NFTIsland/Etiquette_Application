const caver = require('caver-js');
const wallet = require('../../../service/kas/wallet');

const klayTransaction = async function (req, res) {
    try {
        // req.body.value의 경우 string이든 int든 관계없음
        const peb = caver.utils.convertToPeb(req.body.value, 'KLAY'); // KLAY를 Peb으로 환산
        const hexpeb = caver.utils.numberToHex(peb);
        const transaction = await wallet.kasKlayTransaction(req.body.from, hexpeb, req.body.to);

        if (transaction['statusCode'] == 200) {
            res.status(200);
            res.json({statusCode: 200, transactionHash: transaction['data']['transactionHash']});
        } else {
            const errorCode = transaction['data']['code'];
            res.status(transaction['statusCode']);

            switch (errorCode) {
                case 1000000:
                    res.json({statusCode: transaction['statusCode'], msg: "송신자와 수신자의 주소가 같습니다."});
                    break;                
                case 1061609:
                    res.json({statusCode: transaction['statusCode'], msg: "송신자 또는 수신자 Klaytn 주소가 올바르지 않습니다. 다시 확인해주세요."});
                    break;
                case 1061615:
                    res.json({statusCode: transaction['statusCode'], msg: "보내는 KLAY 양이 너무 많습니다."});
                    break;
                case 1065001:
                    res.json({statusCode: transaction['statusCode'], msg: "송신자의 잔액이 부족합니다."});
                    break;
                default:
                    res.json({statusCode: transaction['statusCode'], msg: "KLAY 전송에 실패했습니다. 잠시 후 다시 시도해주세요."});
                    break;
            }
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = klayTransaction;