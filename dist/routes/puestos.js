"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const puestoController_1 = require("../controllers/puestoController");
const router = (0, express_1.Router)();
router.get('/', puestoController_1.getPuestos);
exports.default = router;
