import type { $Enums, Prisma } from '../generated/prisma';

export interface createEmployeeRequestDto {
  first_name: string;
  middle_name?: string;
  last_name: string;
  display_name?: string;
  email: string;
  phone?: string;
  dob?: Date;
  gender: 'male' | 'female' | 'other';
  address?: Record<string, any>;
  bank_details?: Record<string, any>;
  national_id?: Record<string, any>;
  joining_date?: Date;
  end_date?: Date;
  password: string;
  department_id?: number;
  designation_id?: number;
  manager_id?: number;
}

export interface employee {
  id: number;
  first_name: string;
  middle_name: string | null;
  last_name: string;
  display_name: string | null;
  email: string;
  phone: string | null;
  dob: Date | null;
  gender: $Enums.Gender | null;
  address: Prisma.JsonValue | null;
  bank_details: Prisma.JsonValue | null;
  national_id: Prisma.JsonValue | null;
  joining_date: Date | null;
  end_date: Date | null;
  status: $Enums.EmployeeStatus | null;
  employment_type: $Enums.EmploymentType | null;
  custom_fields: Prisma.JsonValue | null;
  created_at: Date | null;
  updated_at: Date | null;
  department_id: number | null;
  designation_id: number | null;
  manager_id: number | null;
}
