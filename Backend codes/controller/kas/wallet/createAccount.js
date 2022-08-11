const wallet = require('../../../service/kas/wallet');

const createAccount = async function (req, res) {
    try {
        const account = await wallet.kasCreateAccount();

        if (account['statusCode'] == 200) {
            res.json({statusCode: 200, data: account['data']['address']});
        } else {
            const errorCode = account['data']['code'];

            switch (errorCode) {
                case 1010008:
                    res.json({statusCode: account['statusCode'], msg: '인증키가 유효하지 않습니다. 앱을 종료 후 다시 실행해 주세요.'});
                    break;
                case 1010009:
                    res.json({statusCode: account['statusCode'], msg: '인증키가 올바르지 않습니다. 앱을 종료 후 다시 실행해 주세요.'});
                    break;
                default:
                    res.json({statusCode: account['statusCode'], msg: account['data']['message']});
                    break;
            }
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = createAccount;