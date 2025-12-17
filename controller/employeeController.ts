import type { Request, Response } from 'express';
import { prisma } from '../utils/db';
import type { createEmployeeRequestDto, employee } from '../dto/employee.dto';
import type { ErrorResponse, SuccessResponse } from '../types/apiResponse';
import bcrypt from 'bcrypt';
import { employeeSelector } from '../prisma/selectors/employee';
import { EmployeeStatus } from '../generated/prisma';

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

export const updateEmployee = async (
  req: Request,
  res: Response<SuccessResponse<employee> | ErrorResponse>,
) => {
  try {
    const { id } = req.params;
    const body: Partial<createEmployeeRequestDto & { status: EmployeeStatus }> =
      req.body;

    const existingEmployee = await prisma.employees.findUnique({
      where: { id: Number(id) },
    });

    if (!existingEmployee) {
      return res.status(404).json({
        success: false,
        message: 'Employee not found',
      });
    }

    if (body.email && body.email !== existingEmployee.email) {
      const emailExists = await prisma.employees.findUnique({
        where: { email: body.email },
      });

      if (emailExists) {
        return res.status(409).json({
          success: false,
          message: 'Email already exists',
        });
      }
    }

    let password_hash: string | undefined;
    if (body.password) {
      password_hash = await bcrypt.hash(body.password, 10);
    }

    const updatedEmployee = await prisma.employees.update({
      where: { id: Number(id) },
      data: {
        first_name: body.first_name,
        middle_name: body.middle_name,
        last_name: body.last_name,
        display_name: body.display_name,
        email: body.email,
        phone: body.phone,
        dob: body.dob,
        gender: body.gender,
        address: body.address,
        bank_details: body.bank_details,
        national_id: body.national_id,
        joining_date: body.joining_date
          ? new Date(body.joining_date)
          : undefined,
        end_date: body.end_date,
        department_id: body.department_id,
        designation_id: body.designation_id,
        manager_id: body.manager_id,
        password_hash,
        status: body.status,
      },
      select: employeeSelector,
    });

    return res.status(200).json({
      success: true,
      message: 'Employee updated successfully',
      data: updatedEmployee,
    });
  } catch (e) {
    console.error(e);
    return res.status(400).json({
      success: false,
      message: 'Something went wrong',
    });
  }
};

export const getAllEmployee = async (
  req: Request,
  res: Response<
    (SuccessResponse<employee[]> & { total: number }) | ErrorResponse
  >,
) => {
  try {
    const limit = Number(req.query.limit) || 10;
    const page = Number(req.query.page) || 1;
    const skip = (page - 1) * limit;
    const search = String(req.query.search || '').trim();

    const filters = {
      department_id: req.query.department_id
        ? Number(req.query.department_id)
        : undefined,
      status: req.query.status as string | undefined,
      gender: req.query.gender as string | undefined,
      from_date: req.query.from_date
        ? new Date(String(req.query.from_date))
        : undefined,
      to_date: req.query.to_date
        ? new Date(String(req.query.to_date))
        : undefined,
    };

    const where: any = {};

    if (search) {
      where.OR = [
        { first_name: { contains: search, mode: 'insensitive' } },
        { last_name: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
        { display_name: { contains: search, mode: 'insensitive' } },
      ];
    }

    if (filters.department_id) where.department_id = filters.department_id;
    if (filters.status) where.status = filters.status;
    if (filters.gender) where.gender = filters.gender;

    if (filters.from_date || filters.to_date) {
      where.created_at = {
        ...(filters.from_date && { gte: filters.from_date }),
        ...(filters.to_date && { lte: filters.to_date }),
      };
    }

    const [employees, total] = await Promise.all([
      prisma.employees.findMany({
        where,
        select: employeeSelector,
        skip,
        take: limit,
      }),
      prisma.employees.count({ where }),
    ]);

    res.status(200).json({
      success: true,
      message: 'Successfully loaded employee details',
      total,
      data: employees,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: 'Something went wrong',
    });
  }
};
