import express from 'express';
import { registerUser, signIn } from '../controller/auth';
import { verifyToken } from '../middleware/authMiddleware';

const router = express.Router();

router.post('/register', verifyToken, registerUser);

router.post('/login', signIn);

export default router;
