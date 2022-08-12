const BasicAuthDio = require('../../model/kasBasicAuthDio');
const process = require('../process');

const kasKip17TokenMinting = async function (_category, to, token_id, metadata_uri) {
    var category = _category;
    if (_category == "영화") {
        category = "movie";
    } else if (_category == "콘서트") {
        category = "concert";
    } else if (_category == "뮤지컬") {
        category = "musical";
    } else if (_category == "공연") {
        category = "performance";
    } else if (_category == "스포츠") {
        category = "sports";
    } else {
        return {
            "statusCode": 400,
            data: {
                "code": 1000000,
                "msg": "카테고리가 올바르지 않습니다.",
            }
        }
    }

    const alias = category; // alias(별칭) 지정

    const dio = new BasicAuthDio('POST', `https://kip17-api.klaytnapi.com/v2/contract/${alias}/token`, {
        "to": to,
        "id": token_id,
        "uri": metadata_uri,
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

const kasKip17DeleteToken = async function (category, token_id, from) {
    if (category != "movie" && category != "concert" && category != "musical" && category != "performance" && category != "sports") {
        return {
            "statusCode": 400,
            data: {
                "code": 1000000,
                "msg": "카테고리가 올바르지 않습니다.",
            }
        }
    }

    const alias = category; // alias(별칭) 지정

    const dio = new BasicAuthDio('DELETE', `https://kip17-api.klaytnapi.com/v2/contract/${alias}/token/${token_id}`, {
        "from": from,
    });

    return await process(dio);
}

module.exports = {
    kasKip17TokenMinting,
    kasKip17TokenTransfer,
    kasKip17DeleteToken
}