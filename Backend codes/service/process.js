const request = require('request');

module.exports = async function process(dio) {
    function getData() {
        return new Promise((resolve, reject) => {
            request(dio, function (err, res, body) {
                if (!err && res.statusCode == 200) {
                    resolve({statusCode: res.statusCode, data: body});
                } else if (err) {
                    reject({statusCode: 400, msg: err});
                } else {
                    resolve({statusCode: res.statusCode, data: body});
                }
            });
        });
    }

    return getData().then(function(data) {
        return data;
    }).catch(function (err) {
        return err;
    });
}
