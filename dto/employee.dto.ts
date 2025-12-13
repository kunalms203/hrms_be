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
