const express = require("express");
const router = express.Router();

const signup = require("../controller/auth/signup");
const login = require("../controller/auth/login");
const home = require("../controller/auth/home");
const updatePassword = require("../controller/auth/updatePassword");
const updateNickname = require("../controller/auth/updateNickname");
const checkNickname = require("../controller/auth/checkNickname");
const checkPassword = require("../controller/auth/checkPassword");
const kasAddress = require("../controller/auth/kasAddress");
const sendEmail = require("../controller/auth/sendEmail");
const sendRandomPW = require("../controller/auth/sendRandomPW");

router.post('/signup', signup);
router.post('/login', login);
router.get('/data', home);
router.post('/updatePassword', updatePassword);
router.post('/updateNickname', updateNickname);
router.post('/checkNickname', checkNickname);
router.post('/checkPassword', checkPassword);
router.post('/kas_address', kasAddress);
router.post('/sendEmail', sendEmail);
router.post('/sendRandomPW', sendRandomPW);

module.exports = router;