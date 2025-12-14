/*
  Warnings:

  - You are about to drop the column `employee_code` on the `employees` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX "employees_employee_code_key";

-- AlterTable
ALTER TABLE "employees" DROP COLUMN "employee_code";
