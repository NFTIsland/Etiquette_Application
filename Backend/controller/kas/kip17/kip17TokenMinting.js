const kip17 = require('../../../service/kas/kip17');

const kip17TokenMinting = async function (req, res) {
    try {
        const tokenMinting = await kip17.kasKip17TokenMinting(req.body.category, req.body.to, req.body.token_id, req.body.metadata_uri);

        if (tokenMinting['statusCode'] == 200) {
            res.status(200);
            res.json({statusCode: 200});
        } else { 
            const errorCode = tokenMinting['data']['code'];
            res.status(tokenMinting['statusCode']);

            switch (errorCode) {
                case 1000000:
                    res.json({statusCode: tokenMinting['statusCode'], msg: "카테고리가 올바르지 않습니다."});
                    break;
                case 1100251:
                    res.json({statusCode: tokenMinting['statusCode'], msg: "컨트랙트 배포를 확인중입니다."});
                    break;
                case 1104700:
                    res.json({statusCode: tokenMinting['statusCode'], msg: "유효하지 않은 별칭입니다."});
                    break;
                case 1010009:
                    res.json({statusCode: tokenMinting['statusCode'], msg: "자격증명 정보가 유효하지 않습니다."});
                    break;
                case 1100050:
                    res.json({statusCode: tokenMinting['statusCode'], msg: "토큰 소유자 주소가 잘못 되었습니다."});
                    break;
                case 1104400:
                    res.json({statusCode: tokenMinting['statusCode'], msg: "중복된 별칭입니다."});
                    break;
                default:
                    res.json({statusCode: tokenMinting['statusCode'], msg: tokenMinting['data']['message']});
                    break;
            }
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = kip17TokenMinting;