require("dotenv").config()

class BasicAuthDio {
    constructor(method, url, body) {
        this.method = method;
        this.url = url;

        this.headers = {
            'Content-Type': 'application/json',
            'x-chain-id': '1001',
            'Authorization': process.env.AUTHORIZATION,
        };

        if (!body) {
            this.body = {};
        } else {
            this.body = body;
        }

        this.json = true;
    }
}

module.exports = BasicAuthDio;
