import type { employee } from './employee.dto';

export interface RegisterRequestDto {
  first_name: string;
  last_name: string;
  email: string;
  password: string;
  role_id: number;
}

export interface SignInRequestDto {
  email: string;
  password: string;
}

export interface AuthResponseDto {
  token: string;
  createdUser?: employee;
}
