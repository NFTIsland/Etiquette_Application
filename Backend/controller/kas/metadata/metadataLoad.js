const metadata = require('../../../service/kas/metadata');

const metadataLoad = async function (req, res) {
    try {
        const load = await metadata.kasMetadataLoad(req.body.metadata_uri);

        if (load['statusCode'] == 200) {
            res.status(200);
            res.json({json: load});
        } else {
            res.status(load['statusCode']);
            res.json({statusCode: load['statusCode'], msg: '존재하지 않는 메타데이터 uri 입니다.'});
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = metadataLoad;