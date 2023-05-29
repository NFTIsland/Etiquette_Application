const caver = require('caver-js');
const wallet = require('../../../service/kas/wallet');

const getBalance = async function (req, res) {
    try {
        const balance = await wallet.kasGetBalance(req.body.address);
        /*
        {
            statusCode: 200,
            data: { 
                jsonrpc: '2.0', 
                id: 1, 
                result: '0xd021016eee82c4b000' 
            }
        }
        */

        /*
        {
            statusCode: 200,
            data: {
                jsonrpc: '2.0',
                id: 1,
                error: {
                    code: -32602,
                    message: 'invalid argument 0: json: cannot unmarshal hex string without 0x prefix into Go value of type common.Address'
                }
            }
        }
        */

        if (balance['data']['result'] != undefined) {
            const peb = caver.utils.hexToNumberString(balance['data']['result']);
            const klay = caver.utils.convertFromPeb(peb); // peb을 klay로 변환
            res.status(200);
            res.json({statusCode: 200, data: klay});
        } else {
            const errorCode = balance['data']['code'];

            if (errorCode === undefined) {
                res.status(400);
                res.json({statusCode: 400, msg: "주소가 잘못되었습니다."});
                return;
            }

            res.status(balance['statusCode']);
            switch (errorCode) {
                case 1034120:
                    res.json({statusCode: balance['statusCode'], msg: "주소가 잘못되었습니다."});
                    break;
                case 1035200:
                    res.json({statusCode: balance['statusCode'], msg: "서버 에러가 발생했습니다."});
                    break;                
                default:
                    res.json({statusCode: balance['statusCode'], msg: "잔액 확인에 실패했습니다. 잠시 후 다시 시도해주세요."});
                    break;
            }
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = getBalance;