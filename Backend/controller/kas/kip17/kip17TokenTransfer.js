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
                case 1010007:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: "입력한 경로(path)나 동작(method)이 잘못 되었습니다."});
                    break;
                case 1010009:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: "자격증명 정보가 유효하지 않습니다."});
                    break;
                case 1100050:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: "입력한 데이터 형식이 잘못 되었습니다."});
                    break;
                case 1100101:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: "존재하지 않는 데이터입니다."});
                    break;
                case 1104401:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: "KRN 값을 잘못 입력했습니다. 발신자 계정 저장소를 확인해주세요."});
                    break;
                case 1100251:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: "컨트랙트 배포를 확인중입니다."});
                    break;
                case 1104404:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: "해당 토큰을 찾을 수 없습니다."});
                    break;
                case 1104700:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: "유효하지 않은 별칭입니다. 제약 사항을 참고해주세요."});
                    break;
                case 1104801:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: "해당 토큰을 전송할 권한이 없습니다."});
                    break;
                default:
                    res.json({statusCode: tokenTransfer['statusCode'], msg: tokenTransfer['data']['message']});
                    break;
            }
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = kip17TokenTransfer;