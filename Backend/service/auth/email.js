const nodemailer = require('nodemailer');

const email = async function (to, subject, html) {
    try {
        return new Promise((resolve, reject) => {
            const transporter = nodemailer.createTransport({
                service: 'gmail',
                port: 465,
                secure: true,
                auth: {
                    user: process.env.NODEMAILER_USER,
                    pass: process.env.NODEMAILER_PASS,
                },
            });

            const emailOptions = {
                from: process.env.NODEMAILER_USER,
                to: to,
                subject: subject,
                html: html
            };

            transporter.sendMail(emailOptions, function (error, info) {
                if (error) {
                    console.log(error);
                    reject(false);
                } else {
                    console.log('Email sent: ' + info.response);
                    resolve(true);
                }
            });
        });
    } catch (e) {
        console.error(e);
    }
}

module.exports = email;