const wallet = require('../../../service/kas/wallet');

const transactionRetrieve = async function (req, res) {
    try {
        const transactionHash = req.params.transactionHash;
        const retrieve = await wallet.kasTransactionRetrieve(transactionHash);

        if (retrieve['statusCode'] == 200) {
            res.status(200);
            res.json({statusCode: 200, data: retrieve['data']['status']});
        } else {
            const errorCode = retrieve['data']['code'];
            res.status(retrieve['statusCode']);

            switch (errorCode) {
                case 1000000:
                    res.json({statusCode: retrieve['statusCode'], msg: "트랜젝션 Hash 값이 존재하지 않습니다."});
                    break;                
                default:
                    res.json({statusCode: retrieve['statusCode'], msg: "Unknown error occurred"});
                    break;
            }
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = transactionRetrieve;