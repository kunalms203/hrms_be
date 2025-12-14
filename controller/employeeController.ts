import type { Request, Response } from 'express';
import { prisma } from '../utils/db';
import type { createEmployeeRequestDto, employee } from '../dto/employee.dto';
import type { ErrorResponse, SuccessResponse } from '../types/apiResponse';
import bcrypt from 'bcrypt';
import { employeeSelector } from '../prisma/selectors/employee';

export const createEmployee = async (
  req: Request,
  res: Response<SuccessResponse<employee> | ErrorResponse>,
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
      select: employeeSelector,
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

export const getEmpoyeeDetails = async (
  req: Request,
  res: Response<SuccessResponse<employee> | ErrorResponse>,
) => {
  try {
    const { id } = req.params;

    const employee = await prisma.employees.findUnique({
      where: {
        id: Number(id),
      },
      select: employeeSelector,
    });

    if (!employee) {
      return res.status(404).json({
        success: false,
        message: 'Employee not found',
      });
    }

    res.status(200).json({
      success: true,
      message: `Successfully found the emlpoyee with id ${id}`,
      data: employee,
    });
  } catch (e) {
    console.log('error occurred ', e);
    return res.status(400).json({
      success: false,
      message: 'Something went wrong!',
    });
  }
};
