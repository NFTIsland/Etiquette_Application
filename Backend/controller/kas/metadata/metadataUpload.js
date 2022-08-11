const metadata = require('../../../service/kas/metadata');

const metadataUpload = async function (req, res) {
    try {
        const upload = await metadata.kasMetadataUpload(req.body.metadata);

        if (upload['statusCode'] == 200) {
            res.status(200);
            res.json({statusCode: 200, data: upload['data']['result']});
        } else {
            const errorCode = upload['data']['code'];
            res.status(upload['statusCode']);

            switch (errorCode) {
                case 1174401:
                    res.json({statusCode: upload['statusCode'], msg: "입력한 데이터가 유효하지 않습니다."});
                    break;
                case 1174402:
                    res.json({statusCode: upload['statusCode'], msg: "JSON 포맷이 잘못되었습니다."});
                    break; 
                case 1174403:
                    res.json({statusCode: upload['statusCode'], msg: "메타데이터 JSON 포맷이 잘못되었습니다."});
                    break;
                case 1174404:
                    res.json({statusCode: upload['statusCode'], msg: "파일명이 잘못되었습니다."});
                    break;
                case 1174404:
                    res.json({statusCode: upload['statusCode'], msg: "중복된 파일명입니다."});
                    break;
                case 1175602:
                    res.json({statusCode: upload['statusCode'], msg: "데이터가 존재하지 않습니다."});
                    break;
                default:
                    res.json({statusCode: upload['statusCode'], msg: upload['data']['message']});
                    break;
            }
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = metadataUpload;