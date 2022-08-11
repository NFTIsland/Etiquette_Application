const BasicAuthDio = require('../../model/kasBasicAuthDio');
const process = require('../process');

const kasMetadataUpload = async function (metadata) {
    const dio = new BasicAuthDio('POST', 'https://metadata-api.klaytnapi.com/v1/metadata', {
        "metadata": metadata,
    });
    return await process(dio);
}

const kasMetadataLoad = async function (metadata_uri) {
    return await process(metadata_uri);
}

module.exports = {
    kasMetadataUpload,
    kasMetadataLoad
}