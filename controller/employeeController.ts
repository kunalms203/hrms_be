import type { Request, Response } from 'express';
import { prisma } from '../utils/db';
import type { createEmployeeRequestDto } from '../dto/employee.dto';
import type { ErrorResponse, successResponse } from '../types/apiResponse';
import bcrypt from 'bcrypt';
import type { employees } from '../generated/prisma';

export const createEmployee = async (
  req: Request,
  res: Response<successResponse<employees> | ErrorResponse>,
) => {
  try {
    const body: createEmployeeRequestDto = req.body;

    if (!body.first_name || !body.last_name || !body.email || !body.password) {
      return res.status(403).json({
        success: false,
        message: 'You must fill mandatory feilds',
      });
    }

    const exsistingEmployee = await prisma.employees.findUnique({
      where: {
        email: body.email,
      },
    });

    if (exsistingEmployee) {
      return res.status(409).json({
        success: false,
        message: 'Email already exsists!',
      });
    }

    const hashed_password = await bcrypt.hash(body.password, 10);

    const employee = await prisma.employees.create({
      data: {
        first_name: body.first_name,
        last_name: body.last_name,
        email: body.email,
        password_hash: hashed_password,
        phone: body.phone,
        address: body.address,
        middle_name: body.middle_name,
        display_name:
          body.display_name || `${body.first_name} ${body.last_name}`,
        dob: body.dob,
        gender: body.gender,
        bank_details: body.bank_details,
        national_id: body.national_id,
        joining_date: body.joining_date
          ? new Date(body.joining_date)
          : undefined,
        end_date: body.end_date,
        department_id: body.department_id,
        designation_id: body.designation_id,
        manager_id: body.manager_id,
      },
    });

    return res.status(201).send({
      success: true,
      message: 'Employee Created Sucessfully',
      data: employee,
    });
  } catch (e) {
    console.log(e);
    return res.status(400).json({
      success: false,
      message: 'Something went wrong',
    });
  }
};
