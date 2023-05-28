const BasicDio = require('../../model/basicDio');
const process = require('../process');

const getCurrency = async function () {
    try {
            const dio = new BasicDio('GET', 'https://api.coinone.co.kr/public/v2/ticker_new/KRW/KLAY');
            return await process(dio);
    } catch (e) {
            console.error(e);
    }
}

module.exports = {
        getCurrency
}