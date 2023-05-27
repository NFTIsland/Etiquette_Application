const Screen = require('../../model/screen');

const homePosters = async function (req, res) {
    try {
        Screen.getHomePosters(function (err, row) {
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
                    msg: "서버 상태가 원활하지 않습니다. 잠시 후 시도해주세요."
                });
                console.log(`homePosters: ${err}`);
            }
        });
    } catch (e) {
        console.error(e);
    }
}

module.exports = homePosters;