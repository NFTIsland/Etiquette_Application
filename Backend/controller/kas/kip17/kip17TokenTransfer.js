const wallet = require('../../../service/kas/wallet');
const kip17 = require('../../../service/kas/kip17');

const kip17TokenTransfer = async function (req, res) {
    try {
        const check = await wallet.kasCheckAccount(req.body.to);

        if (check['statusCode'] != 200) {
            res.status(400);
            res.json({statusCode: 400, msg: "수신자의 주소가 올바르지 않습니다."});
            return;
        }
    } catch (e) {
        console.log(e);
        return;
    }

    try {
        const tokenTransfer = await kip17.kasKip17TokenTransfer(req.body.alias, req.body.token_id, req.body.sender, req.body.owner, req.body.to);

        if (tokenTransfer['statusCode'] == 200) {
            res.status(200);
            res.json({statusCode: 200});
        } else {
            const errorCode = tokenTransfer['data']['code'];
            res.status(tokenTransfer['statusCode']);

            switch (errorCode) {
                case 1000000:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: "송신자와 수신자의 주소가 같습니다."});
                    break;
                case 1104404:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: "해당 토큰을 찾을 수 없습니다."});
                    break;
                default:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: "토큰 전송에 실패했습니다. 고객센터에 문의해 주세요."});
                    break;
            }
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = kip17TokenTransfer;