const jwt = require('jsonwebtoken');

const home = async function (req, res) {
    try {
        var str = req.get('Authorization');
        jwt.verify(str, KEY, { algorithm: 'HS256' });
        res.send("Welcome");
    } catch (e) {
        console.error(e);
        res.status(401);
        res.send("Bad Token");
    }
}

module.exports = home;