const wallet = require('../../../service/kas/wallet');

const checkAccount = async function (req, res) {
    try {
        const address = req.params.address;
        const check = await wallet.kasCheckAccount(address);

        if (check['statusCode'] == 200) {
            res.status(200);
            res.json({statusCode: 200});
        } else {
            const errorCode = check['data']['code'];
            res.status(check['statusCode']);

            switch (errorCode) {
                case 1000000:
                    res.json({statusCode: check['statusCode'], msg: '주소가 입력되지 않았습니다.'});
                    break;
                case 1010008:
                    res.json({statusCode: check['statusCode'], msg: '서버와의 네트워크 상태가 원활하지 않습니다. 잠시 후 다시 시도해주세요.'});
                    break;
                case 1010007:
                case 1061010:
                case 1061609:
                    res.json({statusCode: check['statusCode'], msg: '존재하지 않는 KAS 주소입니다.'});
                    break;
                case 1065102:
                    res.json({statusCode: check['statusCode'], msg: '해당 주소는 사용할 수 없습니다. 다른 주소를 사용해주세요.'});
                    break;
                default:
                    res.json({statusCode: account['statusCode'], msg: check['data']['message']});
                    break;
            }
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = checkAccount;
