const kip17 = require('../../../service/kas/kip17');

const kip17GetTokenData = async function (req, res) {
    try {
        const tokenData = await kip17.kasKip17GetTokenData(req.body.alias, req.body.token_id);

        if (tokenData['statusCode'] == 200) {
            res.status(200);
            res.json({statusCode: 200, data: tokenData['data']});
        } else {
            const errorCode = tokenData['data']['code'];
            res.status(tokenData['statusCode']);

            switch (errorCode) {
                case 1104404:
                    res.json({
                        statusCode: tokenData['statusCode'],
                        msg: "조회할 토큰이 존재하지 않습니다."
                    });
                    break;
                default:
                    res.json({
                        statusCode: tokenData['statusCode'],
                        msg: "토큰을 조회할 수 없습니다. 고객센터에 문의해 주세>요."
                    });
            }
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = kip17GetTokenData;