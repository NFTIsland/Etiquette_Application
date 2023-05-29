const BasicAuthDio = require('../../model/kasBasicAuthDio');
const process = require('../process');

const kasCreateAccount = async function () {
    const dio = new BasicAuthDio('POST', 'https://wallet-api.klaytnapi.com/v2/account');
    return await process(dio);
}

const kasCheckAccount = async function (address) {
    if (address === undefined) {
        return {
            "statusCode": 404,
            data: {
                "code": 1000000,
                "message": "주소값이 존재하지 않습니다."
            }
        }
    }
    const dio = new BasicAuthDio('GET', `https://wallet-api.klaytnapi.com/v2/account/${address}`);
    return await process(dio);
}

const kasGetBalance = async function (address) {
    const dio = new BasicAuthDio('POST', 'https://node-api.klaytnapi.com/v1/klaytn', {
        "id": 1,
        "jsonrpc": "2.0",
        "method": "klay_getBalance",
        "params": [address, "latest"]
    });
    return await process(dio);
}

const kasKlayTransaction = async function (from, value, to) {
    // 송신자와 수신자의 주소가 같을 경우 KLAY 전송 요청을 취소함
    if (from === to) {
        return {
            "statusCode": 400,
            data: {
                "code": 1000000,
                "message": "송신자와 수신자의 주소가 같습니다.",
            }
        }
    }

    const dio = new BasicAuthDio('POST', 'https://wallet-api.klaytnapi.com/v2/tx/value', {
        "from": from,
        "value": value,
        "to": to,
        "submit": true,
    });
    return await process(dio);
}

const kasTransactionRetrieve = async function (transaction_hash) {
    if (transaction_hash === "") {
        return {
            "statusCode": 400,
            data: {
                "code": 1000000,
                "msg": "트랜젝션 Hash 값이 존재하지 않습니다.",
            }
        }
    }

    const dio = new BasicAuthDio(
        'GET',
        `https://wallet-api.klaytnapi.com/v2/tx/${transaction_hash}`
    );
    return await process(dio);
}

const kasTransactionHistory = async function (address, type, period) {
    var range = "";

    if (period === '1w') { // 1주일
        range = parseInt(((Date.now() - 604800000) / 1000)).toString();
    } else if (period === '1m') { // 1개월
        range = parseInt(((Date.now() - 2592000000) / 1000)).toString();
    } else if (period === '3m') { // 3개월
        range = parseInt(((Date.now() - 7776000000) / 1000)).toString();
    }

    var kind = "";

    if (type === "all") {
        kind = "nft,klay";
    } else if (type === 'klay_deposit' || type === 'klay_withdraw') {
        kind = "klay";
    } else if (type === 'ticket_buy' || type === 'ticket_sell') {
        kind = "nft";
    }

    var dio;

    if (type ==='all') {
        dio = new BasicAuthDio(
            'GET',
            `https://th-api.klaytnapi.com/v2/transfer/account/${address}?kind=${kind}&size=200&exclude-zero-klay=true&range=${range}`
        );
    } else if (type === 'klay_deposit' || type === 'ticket_buy') {
        dio = new BasicAuthDio(
            'GET',
            `https://th-api.klaytnapi.com/v2/transfer/account/${address}?kind=${kind}&size=200&exclude-zero-klay=true&range=${range}&to-only=true`
        );
    } else if (type === 'klay_withdraw' || type === 'ticket_sell') {
        dio = new BasicAuthDio(
            'GET',
            `https://th-api.klaytnapi.com/v2/transfer/account/${address}?kind=${kind}&size=200&exclude-zero-klay=true&range=${range}&from-only=true`
        );
    }

    return await process(dio);
}

module.exports = {
    kasCreateAccount,
    kasCheckAccount,
    kasGetBalance,
    kasKlayTransaction,
    kasTransactionRetrieve,
    kasTransactionHistory
}