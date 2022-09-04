require("dotenv").config()

class MetadataUploadDio {
    constructor(method, url, body) {
        this.method = method;
        this.url = url;

        this.headers = {
            'Content-Type': 'application/json',
            'x-chain-id': '1001',
            'Authorization': process.env.AUTHORIZATION,
            'x-krn': process.env.X-KRN,
        };

        if (!body) {
            this.body = {};
        } else {
            this.body = body;
        }

        
        this.json = true;
    }
}

module.exports = MetadataUploadDio;