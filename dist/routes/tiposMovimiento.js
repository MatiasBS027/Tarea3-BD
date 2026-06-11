"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const tiposMovimientoController_1 = require("../controllers/tiposMovimientoController");
const router = (0, express_1.Router)();
router.get('/', tiposMovimientoController_1.getTiposMovimiento);
exports.default = router;
