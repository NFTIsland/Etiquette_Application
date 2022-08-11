const BasicAuthDio = require('../../model/kasBasicAuthDio');
const process = require('../process');

const kasCreateAccount = async function () {
    const dio = new BasicAuthDio('POST', 'https://wallet-api.klaytnapi.com/v2/account');
    return await process(dio);
}

const kasCheckAccount = async function (address) {
    const dio = new BasicAuthDio('GET', `https://wallet-api.klaytnapi.com/v2/account/${address}`);
    return await process(dio);
}

module.exports = {
    kasCreateAccount,
    kasCheckAccount
}