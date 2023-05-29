const wallet = require('../../../service/kas/wallet');

const createAccount = async function (req, res) {
    try {
        const account = await wallet.kasCreateAccount();

        if (account['statusCode'] == 200) {
            res.json({statusCode: 200, data: account['data']['address']});
        } else {
            res.json({statusCode: account['statusCode'], msg: "KAS 계정 생성에 실패했습니다. 잠시 후 다시 시도해주세요."});
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = createAccount;