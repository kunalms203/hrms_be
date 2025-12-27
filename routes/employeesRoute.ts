import express from 'express';
import { verifyToken } from '../middleware/authMiddleware';
import {
  createEmployee,
  getAllEmployee,
  getEmpoyeeDetails,
  updateEmployee,
} from '../controller/employeeController';

const router = express.Router();

router.post('/', verifyToken, createEmployee);
router.get('/:id', verifyToken, getEmpoyeeDetails);
router.get('/', verifyToken, getAllEmployee);
router.put('/:id', verifyToken, updateEmployee);

export default router;
