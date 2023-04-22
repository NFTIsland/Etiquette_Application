class BasicDio {
    constructor(method, url, body) {
        this.method = method;
        this.url = url;
        this.headers = {
            'Content-Type': 'application/json',
        }

        if (!body) {
            this.body = {};
        } else {
            this.body = body;
        }

        this.json = true;
    }
}

module.exports = BasicDio;