const BasicAuthDio = require('../../model/kasBasicAuthDio');
const process = require('../process');

const kasKip17GetTokenData = async function (alias, token_id) {
    const dio = new BasicAuthDio('GET', `https://kip17-api.klaytnapi.com/v2/contract/${alias}/token/${token_id}`, {
        "alias": alias,
        "token_id": token_id,
    });

    return await process(dio);
}

const kasKip17TokenTransfer = async function (alias, token_id, sender, owner, to) {
    if (sender === to) {
        return {
            "statusCode": 400,
            data: {
                "code": 1000000,
                "msg": "송신자와 수신자의 주소가 같습니다.",
            }
        }
    }

    const dio = new BasicAuthDio('POST', `https://kip17-api.klaytnapi.com/v2/contract/${alias}/token/${token_id}`, {
        "sender": sender,
        "owner": owner,
        "to": to,
    });

    return await process(dio);
}



module.exports = {
    kasKip17GetTokenData,
    kasKip17TokenTransfer
}