import express from 'express';
import { verifyToken } from '../middleware/authMiddleware';
import {
  createEmployee,
  getEmpoyeeDetails,
} from '../controller/employeeController';

const router = express.Router();

router.post('/', verifyToken, createEmployee);
router.get('/:id', verifyToken, getEmpoyeeDetails);

export default router;
