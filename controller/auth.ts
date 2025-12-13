import type { Request, Response } from 'express';
import { prisma } from '../utils/db';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import type {
  AuthResponseDto,
  RegisterRequestDto,
  SignInRequestDto,
} from '../dto/user.dto';
import type { ErrorResponse, successResponse } from '../types/apiResponse';

const secret = process.env.JWT_SECRET;

if (!secret) {
  throw new Error('Secret is not defined');
}

export const registerUser = async (
  req: Request,
  res: Response<ErrorResponse | successResponse<AuthResponseDto>>,
) => {
  try {
    const user: RegisterRequestDto = req.body;

    const { first_name, last_name, email, password } = user;

    const alreadyExsist = await prisma.employees.findUnique({
      where: {
        email: email,
      },
      select: {
        email: true,
      },
    });

    if (alreadyExsist) {
      return res.status(409).json({
        success: false,
        message: 'user already exists',
      });
    }

    if (!first_name || !last_name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'first_name, last_name, email, password_hash are required.',
      });
    }

    const password_hash: string = await bcrypt.hash(password, 10);

    const createdUser = await prisma.employees.create({
      data: {
        first_name,
        last_name,
        email,
        password_hash,
      },
    });

    const token = jwt.sign(
      {
        id: createdUser.id,
        name: `${createdUser.first_name} ${createdUser.last_name}`,
      },
      secret,
    );

    return res.status(201).json({
      success: true,
      message: 'Account Created Successfully',
      data: { token },
    });
  } catch (e) {
    console.log('error occured', e);
    res.status(400).json({
      success: false,
      message: 'something went wrong',
    });
  }
};

export const signIn = async (
  req: Request,
  res: Response<ErrorResponse | successResponse<AuthResponseDto>>,
) => {
  try {
    const { email, password }: SignInRequestDto = req.body;

    const ExistedUser = await prisma.employees.findFirst({
      where: {
        email: email,
      },
    });

    if (!ExistedUser) {
      return res.status(404).json({
        success: false,
        message: 'No user found with this email',
      });
    }

    const isValid: boolean = await bcrypt.compare(
      password,
      ExistedUser.password_hash,
    );

    if (!isValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid Credentials',
      });
    }

    const token = jwt.sign(
      {
        id: ExistedUser.id,
        name: `${ExistedUser.first_name} ${ExistedUser.last_name}`,
      },
      secret,
    );

    return res.status(200).json({
      success: true,
      message: 'logged in sucessfully',
      data: { token: token },
    });
  } catch (e) {
    console.log('error occured', e);
    res.status(400).json({
      success: false,
      message: 'something went wrong',
    });
  }
};
