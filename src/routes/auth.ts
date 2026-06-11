import { Router, Request, Response } from 'express';
import { AuthController } from '../controllers/authController';
import { validateLogin } from '../middleware/validation';
import { authenticate } from '../middleware/authMiddleware';

const router = Router();
const authController = new AuthController();

router.post('/login', validateLogin, (req: Request, res: Response) => {
    void authController.login(req, res);
});

router.post('/logout', authenticate, (req: Request, res: Response) => {
    void authController.logout(req, res);
});

export default router;
