const Screen = require('../../model/screen');

const homeNotices = async function (req, res) {
    try {
        Screen.getHomeNotices(function (err, row) {
            if (row != undefined && row.length) {
                res.status(200);
                res.json({
                    statusCode: 200,
                    data: row
                });
            } else {
                res.status(411)
                res.json({
                    statusCode: 411,
                    msg: "서버와의 상태가 원활하지 않습니다. 잠시 후 다시 시도해주세요."
                });
                console.log(`homeNotices: ${err}`);
            }
        });
    } catch (e) {
        console.error(e);
    }
}

module.exports = homeNotices;