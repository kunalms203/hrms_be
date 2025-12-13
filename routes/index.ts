import express from 'express';
import authRouter from './authRouter';
import employeeRouter from './employeesRoute';

const router = express.Router();

router.use('/auth', authRouter);
router.use('/employee', employeeRouter);

export default router;
