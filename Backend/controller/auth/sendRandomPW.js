const email = require('../../service/auth/email');
const Auth = require("../../model/auth");

function createRandomPW(variable, passwordLength) {
    var randomString = "";
    for (var i = 0; i < passwordLength; i++)
        randomString += variable[Math.floor(Math.random() * variable.length)];
    return randomString;
}

const sendRandomPW = async function (req, res) {
    try {
        const variable = "0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z".split(",");
        const randomPassword = createRandomPW(variable, 8);
        const subject = "Etiquette 임시 비밀번호 알림";
        const html = `\
        <h1>Etiquette에서 새로운 임시 비밀번호를 알려드립니다.</h1> \
        <h2> 비밀번호 : ${randomPassword} </h2> \
        <h3 style="color: crimson;">임시 비밀번호로 로그인하신 후, 반드시 비밀번호를 변경해 주십시오. </h3>`;
        const result = await email(req.body.email, subject, html);
        if (result) {
            Auth.updatePW(req.body.id, randomPassword, function (err, row) {
                if (!err) {
                    res.status(200);
                    res.json({
                        statusCode: 200,
                        msg: "임시 비밀번호가 전송되었습니다."
                    });
                } else {
                    res.status(401);
                    res.json({
                        statusCode: 401,
                        msg: "임시 비밀번호 설정에 오류가 발생했습니다. 다시 시도해주세요."
                    });
                    console.log(`sendRandomPW - updatePassword: ${err}`);
                }
            });
        } else {
            res.status(401);
            res.json({
                statusCode: 401,
                msg: "임시 비밀번호 전송에 실패했습니다. 다시 시도해주세요."
            });
        }
    } catch (e) {
        console.error(e);
    }
}

module.exports = sendRandomPW;