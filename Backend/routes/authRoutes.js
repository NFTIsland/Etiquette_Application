const express = require("express");
const router = express.Router();
const authController = require("../controller/authController");

router.post('/login', authController.login);
router.get('/data', authController.home);
router.post('/signup', authController.signup);
router.post('/updatePassword', authController.updatePassword);
router.post('/updateNickname', authController.updateNickname);
router.post('/checkNickname', authController.checkNickname);
router.post('/checkPassword', authController.checkPassword);
router.post('/kas_address', authController.kasAddress);

module.exports = router;