"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const authController_1 = require("../controllers/authController");
const validation_1 = require("../middleware/validation");
const authMiddleware_1 = require("../middleware/authMiddleware");
const router = (0, express_1.Router)();
const authController = new authController_1.AuthController();
router.post('/login', validation_1.validateLogin, (req, res) => {
    void authController.login(req, res);
});
router.post('/logout', authMiddleware_1.authenticate, (req, res) => {
    void authController.logout(req, res);
});
exports.default = router;
