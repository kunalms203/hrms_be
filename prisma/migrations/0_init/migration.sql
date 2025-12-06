-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('male', 'female', 'other');

-- CreateEnum
CREATE TYPE "EmploymentType" AS ENUM ('full_time', 'part_time', 'contractor');

-- CreateEnum
CREATE TYPE "EmployeeStatus" AS ENUM ('active', 'terminated', 'on_leave', 'suspended');

-- CreateEnum
CREATE TYPE "AttendanceSource" AS ENUM ('web', 'biometric', 'mobile');

-- CreateEnum
CREATE TYPE "AttendanceStatus" AS ENUM ('present', 'absent', 'holiday', 'leave');

-- CreateEnum
CREATE TYPE "TimesheetStatus" AS ENUM ('draft', 'submitted', 'approved', 'rejected');

-- CreateEnum
CREATE TYPE "LeaveStatus" AS ENUM ('pending', 'approved', 'rejected', 'cancelled');

-- CreateEnum
CREATE TYPE "PayrollComponentType" AS ENUM ('earning', 'deduction', 'statutory');

-- CreateEnum
CREATE TYPE "GoalStatus" AS ENUM ('active', 'completed', 'cancelled');

-- CreateEnum
CREATE TYPE "ReviewMode" AS ENUM ('onsite', 'remote', 'phone');

-- CreateEnum
CREATE TYPE "JobStatus" AS ENUM ('open', 'closed');

-- CreateTable
CREATE TABLE "employees" (
    "id" SERIAL NOT NULL,
    "employee_code" TEXT NOT NULL,
    "first_name" TEXT NOT NULL,
    "middle_name" TEXT,
    "last_name" TEXT NOT NULL,
    "display_name" TEXT,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "dob" TIMESTAMP(3),
    "gender" "Gender",
    "address" JSONB,
    "bank_details" JSONB,
    "national_id" JSONB,
    "joining_date" TIMESTAMP(3),
    "end_date" TIMESTAMP(3),
    "password" TEXT NOT NULL,
    "status" "EmployeeStatus",
    "employment_type" "EmploymentType",
    "custom_fields" JSONB,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),
    "department_id" INTEGER,
    "designation_id" INTEGER,
    "manager_id" INTEGER,

    CONSTRAINT "employees_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employee_documents" (
    "id" SERIAL NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "doc_type" TEXT NOT NULL,
    "file_path" TEXT NOT NULL,
    "file_metadata" JSONB,
    "uploaded_by" INTEGER,
    "uploaded_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "expiry_date" TIMESTAMP(3),
    "verified" BOOLEAN,

    CONSTRAINT "employee_documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "departments" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "parent_department_id" INTEGER,
    "description" TEXT,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "departments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "designations" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "level" INTEGER NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "designations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "roles" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_roles" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "role_id" INTEGER NOT NULL,
    "assigned_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "role_permissions" (
    "id" SERIAL NOT NULL,
    "role_id" INTEGER NOT NULL,
    "permission_key" TEXT NOT NULL,

    CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance_records" (
    "id" SERIAL NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "attendance_date" TIMESTAMP(3) NOT NULL,
    "clock_in" TIMESTAMP(3),
    "clock_out" TIMESTAMP(3),
    "total_work_seconds" INTEGER,
    "source" "AttendanceSource",
    "device_id" TEXT,
    "location" JSONB,
    "status" "AttendanceStatus",
    "notes" TEXT,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "attendance_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "timesheets" (
    "id" SERIAL NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "week_start" TIMESTAMP(3) NOT NULL,
    "week_end" TIMESTAMP(3) NOT NULL,
    "total_hours" DOUBLE PRECISION,
    "status" "TimesheetStatus",
    "submitted_at" TIMESTAMP(3),
    "approved_at" TIMESTAMP(3),
    "approved_by" INTEGER,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "timesheets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "timesheet_entries" (
    "id" SERIAL NOT NULL,
    "timesheet_id" INTEGER NOT NULL,
    "entry_date" TIMESTAMP(3) NOT NULL,
    "project_id" INTEGER,
    "task_description" TEXT,
    "hours" DOUBLE PRECISION,
    "metadata" JSONB,

    CONSTRAINT "timesheet_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leave_types" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "default_allocated_days" DOUBLE PRECISION,
    "carry_forward" BOOLEAN,
    "requires_document" BOOLEAN,
    "accrual_policy" JSONB,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "leave_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leave_applications" (
    "id" SERIAL NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "leave_type_id" INTEGER NOT NULL,
    "start_date" TIMESTAMP(3) NOT NULL,
    "end_date" TIMESTAMP(3) NOT NULL,
    "duration_days" DOUBLE PRECISION,
    "status" "LeaveStatus",
    "applied_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "approved_by" INTEGER,
    "approved_at" TIMESTAMP(3),
    "reason" TEXT,
    "attachment_path" TEXT,
    "manager_comments" TEXT,

    CONSTRAINT "leave_applications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leave_balances" (
    "id" SERIAL NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "leave_type_id" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "total_allocated" DOUBLE PRECISION,
    "used" DOUBLE PRECISION,
    "carry_forward_from_previous" DOUBLE PRECISION,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "leave_balances_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payroll_components" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "component_type" "PayrollComponentType" NOT NULL,
    "tax_applicable" BOOLEAN,
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "payroll_components_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payroll_structures" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "is_default" BOOLEAN,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "payroll_structures_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payroll_structure_components" (
    "id" SERIAL NOT NULL,
    "payroll_structure_id" INTEGER NOT NULL,
    "payroll_component_id" INTEGER NOT NULL,
    "amount" DOUBLE PRECISION,
    "percentage" DOUBLE PRECISION,
    "calculation_rule" TEXT,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "payroll_structure_components_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employee_payroll_assignments" (
    "id" SERIAL NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "payroll_structure_id" INTEGER NOT NULL,
    "effective_from" TIMESTAMP(3) NOT NULL,
    "effective_to" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "employee_payroll_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payslips" (
    "id" SERIAL NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "payroll_period_start" TIMESTAMP(3) NOT NULL,
    "payroll_period_end" TIMESTAMP(3) NOT NULL,
    "gross_pay" DOUBLE PRECISION,
    "total_deductions" DOUBLE PRECISION,
    "net_pay" DOUBLE PRECISION,
    "breakdown" JSONB,
    "generated_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "paid_at" TIMESTAMP(3),
    "payment_reference" TEXT,

    CONSTRAINT "payslips_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "performance_goals" (
    "id" SERIAL NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "kpi_target" JSONB,
    "start_date" TIMESTAMP(3) NOT NULL,
    "end_date" TIMESTAMP(3),
    "status" "GoalStatus",
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "performance_goals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "performance_reviews" (
    "id" SERIAL NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "reviewer_id" INTEGER NOT NULL,
    "review_period_start" TIMESTAMP(3) NOT NULL,
    "review_period_end" TIMESTAMP(3) NOT NULL,
    "overall_rating" DOUBLE PRECISION,
    "summary" TEXT,
    "review_data" JSONB,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "performance_reviews_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "review_feedback" (
    "id" SERIAL NOT NULL,
    "review_id" INTEGER NOT NULL,
    "from_employee_id" INTEGER NOT NULL,
    "feedback_text" TEXT,
    "rating" DOUBLE PRECISION,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "review_feedback_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "jobs" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "department_id" INTEGER NOT NULL,
    "hiring_manager_id" INTEGER NOT NULL,
    "location" TEXT,
    "employment_type" TEXT,
    "status" "JobStatus",
    "posted_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "closed_at" TIMESTAMP(3),
    "description" TEXT,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "applicants" (
    "id" SERIAL NOT NULL,
    "job_id" INTEGER NOT NULL,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "resume_path" TEXT,
    "resume_text" TEXT,
    "source" TEXT,
    "status" TEXT,
    "applied_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "metadata" JSONB,

    CONSTRAINT "applicants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "interviews" (
    "id" SERIAL NOT NULL,
    "applicant_id" INTEGER NOT NULL,
    "scheduled_at" TIMESTAMP(3) NOT NULL,
    "mode" TEXT,
    "interviewers" JSONB,
    "location" TEXT,
    "duration_minutes" INTEGER,
    "outcome" TEXT,
    "notes" TEXT,

    CONSTRAINT "interviews_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "offers" (
    "id" SERIAL NOT NULL,
    "applicant_id" INTEGER NOT NULL,
    "job_id" INTEGER NOT NULL,
    "offered_by" INTEGER NOT NULL,
    "offered_salary" DOUBLE PRECISION,
    "currency" TEXT,
    "offer_letter_path" TEXT,
    "status" TEXT,
    "issued_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "accepted_at" TIMESTAMP(3),

    CONSTRAINT "offers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expenses" (
    "id" SERIAL NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "amount" DOUBLE PRECISION,
    "currency" TEXT,
    "expense_date" TIMESTAMP(3) NOT NULL,
    "category" TEXT,
    "description" TEXT,
    "receipt_path" TEXT,
    "status" TEXT,
    "approved_by" INTEGER,
    "approved_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "expenses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trainings" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "provider" TEXT,
    "start_date" TIMESTAMP(3) NOT NULL,
    "end_date" TIMESTAMP(3) NOT NULL,
    "capacity" INTEGER,
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "trainings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "training_enrollments" (
    "id" SERIAL NOT NULL,
    "training_id" INTEGER NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "status" TEXT,
    "enrolled_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "completed_at" TIMESTAMP(3),
    "certificate_path" TEXT,

    CONSTRAINT "training_enrollments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "announcements" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "posted_by" INTEGER NOT NULL,
    "posted_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "visibility" JSONB,

    CONSTRAINT "announcements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "action" TEXT,
    "entity" TEXT,
    "entity_id" INTEGER,
    "changes" JSONB,
    "ip_address" TEXT,
    "user_agent" TEXT,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "integrations" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "type" TEXT,
    "config" JSONB,
    "enabled" BOOLEAN,
    "last_synced_at" TIMESTAMP(3),

    CONSTRAINT "integrations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "settings" (
    "key" TEXT NOT NULL,
    "value" JSONB,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "settings_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "search_index" (
    "id" SERIAL NOT NULL,
    "entity_type" TEXT NOT NULL,
    "entity_id" INTEGER NOT NULL,
    "payload" TEXT,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "search_index_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "employees_employee_code_key" ON "employees"("employee_code");

-- CreateIndex
CREATE UNIQUE INDEX "employees_email_key" ON "employees"("email");

-- CreateIndex
CREATE UNIQUE INDEX "roles_name_key" ON "roles"("name");

-- CreateIndex
CREATE UNIQUE INDEX "attendance_records_employee_id_attendance_date_key" ON "attendance_records"("employee_id", "attendance_date");

-- CreateIndex
CREATE UNIQUE INDEX "timesheets_employee_id_week_start_key" ON "timesheets"("employee_id", "week_start");

-- CreateIndex
CREATE UNIQUE INDEX "leave_types_code_key" ON "leave_types"("code");

-- CreateIndex
CREATE UNIQUE INDEX "leave_balances_employee_id_leave_type_id_year_key" ON "leave_balances"("employee_id", "leave_type_id", "year");

-- CreateIndex
CREATE UNIQUE INDEX "payroll_components_code_key" ON "payroll_components"("code");

-- CreateIndex
CREATE UNIQUE INDEX "payroll_structure_components_payroll_structure_id_payroll_c_key" ON "payroll_structure_components"("payroll_structure_id", "payroll_component_id");

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_designation_id_fkey" FOREIGN KEY ("designation_id") REFERENCES "designations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_manager_id_fkey" FOREIGN KEY ("manager_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_documents" ADD CONSTRAINT "employee_documents_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_documents" ADD CONSTRAINT "employee_documents_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "departments" ADD CONSTRAINT "departments_parent_department_id_fkey" FOREIGN KEY ("parent_department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timesheets" ADD CONSTRAINT "timesheets_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timesheets" ADD CONSTRAINT "timesheets_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timesheet_entries" ADD CONSTRAINT "timesheet_entries_timesheet_id_fkey" FOREIGN KEY ("timesheet_id") REFERENCES "timesheets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_applications" ADD CONSTRAINT "leave_applications_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_applications" ADD CONSTRAINT "leave_applications_leave_type_id_fkey" FOREIGN KEY ("leave_type_id") REFERENCES "leave_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_applications" ADD CONSTRAINT "leave_applications_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_balances" ADD CONSTRAINT "leave_balances_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_balances" ADD CONSTRAINT "leave_balances_leave_type_id_fkey" FOREIGN KEY ("leave_type_id") REFERENCES "leave_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payroll_structure_components" ADD CONSTRAINT "payroll_structure_components_payroll_structure_id_fkey" FOREIGN KEY ("payroll_structure_id") REFERENCES "payroll_structures"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payroll_structure_components" ADD CONSTRAINT "payroll_structure_components_payroll_component_id_fkey" FOREIGN KEY ("payroll_component_id") REFERENCES "payroll_components"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_payroll_assignments" ADD CONSTRAINT "employee_payroll_assignments_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_payroll_assignments" ADD CONSTRAINT "employee_payroll_assignments_payroll_structure_id_fkey" FOREIGN KEY ("payroll_structure_id") REFERENCES "payroll_structures"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payslips" ADD CONSTRAINT "payslips_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "performance_goals" ADD CONSTRAINT "performance_goals_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "performance_reviews" ADD CONSTRAINT "performance_reviews_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "performance_reviews" ADD CONSTRAINT "performance_reviews_reviewer_id_fkey" FOREIGN KEY ("reviewer_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "review_feedback" ADD CONSTRAINT "review_feedback_review_id_fkey" FOREIGN KEY ("review_id") REFERENCES "performance_reviews"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "review_feedback" ADD CONSTRAINT "review_feedback_from_employee_id_fkey" FOREIGN KEY ("from_employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "jobs" ADD CONSTRAINT "jobs_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "jobs" ADD CONSTRAINT "jobs_hiring_manager_id_fkey" FOREIGN KEY ("hiring_manager_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "applicants" ADD CONSTRAINT "applicants_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "jobs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interviews" ADD CONSTRAINT "interviews_applicant_id_fkey" FOREIGN KEY ("applicant_id") REFERENCES "applicants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "offers" ADD CONSTRAINT "offers_applicant_id_fkey" FOREIGN KEY ("applicant_id") REFERENCES "applicants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "offers" ADD CONSTRAINT "offers_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "jobs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "offers" ADD CONSTRAINT "offers_offered_by_fkey" FOREIGN KEY ("offered_by") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "training_enrollments" ADD CONSTRAINT "training_enrollments_training_id_fkey" FOREIGN KEY ("training_id") REFERENCES "trainings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "training_enrollments" ADD CONSTRAINT "training_enrollments_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "announcements" ADD CONSTRAINT "announcements_posted_by_fkey" FOREIGN KEY ("posted_by") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

