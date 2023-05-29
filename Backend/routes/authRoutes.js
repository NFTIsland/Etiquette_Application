const express = require("express");
const router = express.Router();

const signup = require("../controller/auth/signup");
const login = require("../controller/auth/login");
const updatePassword = require("../controller/auth/updatePassword");
const updateNickname = require("../controller/auth/updateNickname");
const checkNickname = require("../controller/auth/checkNickname");
const checkPassword = require("../controller/auth/checkPassword");
const kasAddress = require("../controller/auth/kasAddress");
const sendRandomPW = require("../controller/auth/sendRandomPW");

router.post('/signup', signup);
router.post('/login', login);
router.post('/updatePassword', updatePassword);
router.post('/updateNickname', updateNickname);
router.post('/checkNickname', checkNickname);
router.post('/checkPassword', checkPassword);
router.post('/kas_address', kasAddress);
router.post('/sendRandomPW', sendRandomPW);

module.exports = router;