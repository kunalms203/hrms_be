import type { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import type { JWTPayload } from '../types/auth';
import { isJWTPayload } from '../utils/jwt';

const secret = process.env.JWT_SECRET;

if (!secret) {
  throw Error('Secret is not defined');
}

export const verifyToken = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const auth = req.header('Authorization');

    const token = auth?.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. Token not found',
      });
    }

    try {
      const decoded = jwt.verify(token, secret) as JWTPayload;

      if (!isJWTPayload(decoded)) {
        res.status(401).json({
          success: false,
          message: 'Invalid token Payload, Unautharized',
        });
      }

      (req as any).user = decoded;
      next();
    } catch {
      return res.status(401).json({
        sucess: false,
        message: 'Expired or Invalid Token',
      });
    }
  } catch (e) {
    console.log('err', e);
    res.status(400).json({
      success: false,
      message: 'Something went wrong',
    });
  }
};
