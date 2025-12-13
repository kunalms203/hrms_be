import express from 'express';
import { verifyToken } from '../middleware/authMiddleware';
import { createEmployee } from '../controller/employeeController';

const router = express.Router();

router.post('/', verifyToken, createEmployee);

export default router;
