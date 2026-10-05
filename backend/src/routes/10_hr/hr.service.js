import Employee from '../../models/Employee.js';
import Department from '../../models/Department.js';
import Designation from '../../models/Designation.js';
import Attendance from '../../models/Attendance.js';
import Leave from '../../models/Leave.js';
import Salary from '../../models/Salary.js';
import Performance from '../../models/Performance.js';
import Training from '../../models/Training.js';
import EmployeeTraining from '../../models/EmployeeTraining.js';
import { Op } from 'sequelize';
import sequelize from '../../config/database.js';

// Employee Management
export const createEmployee = async (orgId, data) => {
  const employeeCode = `EMP-${Date.now().toString().slice(-6)}`;
  
  return await Employee.create({
    organization_id: orgId,
    employee_code: employeeCode,
    ...data,
  });
};

export const getEmployeeById = async (employeeId) => {
  return await Employee.findByPk(employeeId, {
    include: [Department, Designation],
  });
};

export const getAllEmployees = async (orgId, filters = {}) => {
  const where = { organization_id: orgId };
  if (filters.department_id) where.department_id = filters.department_id;
  if (filters.status) where.status = filters.status;
  if (filters.employment_type) where.employment_type = filters.employment_type;

  return await Employee.findAll({
    where,
    include: [Department, Designation],
    order: [['first_name', 'ASC']],
  });
};

export const updateEmployee = async (employeeId, data) => {
  return await Employee.update(data, { where: { id: employeeId } });
};

// Attendance Management
export const markAttendance = async (orgId, data) => {
  return await Attendance.create({
    organization_id: orgId,
    ...data,
  });
};

export const getAttendanceByEmployee = async (employeeId, fromDate, toDate) => {
  return await Attendance.findAll({
    where: {
      employee_id: employeeId,
      attendance_date: { [Op.between]: [fromDate, toDate] },
    },
    order: [['attendance_date', 'ASC']],
  });
};

export const getAttendanceSummary = async (orgId, month) => {
  const startDate = new Date(month.getFullYear(), month.getMonth(), 1);
  const endDate = new Date(month.getFullYear(), month.getMonth() + 1, 0);

  const records = await Attendance.findAll({
    where: {
      organization_id: orgId,
      attendance_date: { [Op.between]: [startDate, endDate] },
    },
    raw: true,
  });

  const summary = {};
  records.forEach(record => {
    if (!summary[record.employee_id]) {
      summary[record.employee_id] = {
        present: 0,
        absent: 0,
        late: 0,
        half_day: 0,
        work_from_home: 0,
      };
    }
    summary[record.employee_id][record.status]++;
  });

  return summary;
};

// Leave Management
export const applyLeave = async (orgId, data) => {
  const leave = await Leave.create({
    organization_id: orgId,
    ...data,
  });
  
  return leave;
};

export const getLeavesByEmployee = async (employeeId) => {
  return await Leave.findAll({
    where: { employee_id: employeeId },
    order: [['from_date', 'DESC']],
  });
};

export const approveLeave = async (leaveId, approvedBy, remarks) => {
  return await Leave.update(
    {
      status: 'approved',
      approved_by: approvedBy,
      approval_date: new Date(),
      remarks,
    },
    { where: { id: leaveId } }
  );
};

export const rejectLeave = async (leaveId, approvedBy, remarks) => {
  return await Leave.update(
    {
      status: 'rejected',
      approved_by: approvedBy,
      approval_date: new Date(),
      remarks,
    },
    { where: { id: leaveId } }
  );
};

export const getPendingLeaves = async (orgId) => {
  return await Leave.findAll({
    where: {
      organization_id: orgId,
      status: 'pending',
    },
    include: [{ model: Employee, include: [Department, Designation] }],
  });
};

// Salary Management
export const createSalarySlip = async (orgId, employeeId, data) => {
  const totalEarnings = (data.base_salary || 0) + 
    (data.dearness_allowance || 0) + 
    (data.house_rent_allowance || 0) + 
    (data.other_allowances || 0);

  const totalDeductions = (data.pf_deduction || 0) + 
    (data.it_deduction || 0) + 
    (data.other_deductions || 0);

  const netSalary = totalEarnings - totalDeductions;

  return await Salary.create({
    organization_id: orgId,
    employee_id: employeeId,
    total_earnings: totalEarnings,
    total_deductions: totalDeductions,
    net_salary: netSalary,
    ...data,
  });
};

export const getSalarySlips = async (employeeId, year, month) => {
  return await Salary.findAll({
    where: {
      employee_id: employeeId,
      salary_month: { [Op.between]: [new Date(year, month - 1, 1), new Date(year, month, 0)] },
    },
  });
};

export const processSalary = async (orgId, month) => {
  const employees = await Employee.findAll({
    where: { organization_id: orgId, status: 'active' },
  });

  return {
    employees_count: employees.length,
    month,
    status: 'processed',
  };
};

// Performance Management
export const createPerformanceReview = async (orgId, data) => {
  return await Performance.create({
    organization_id: orgId,
    ...data,
  });
};

export const getPerformanceReview = async (employeeId, periodStart, periodEnd) => {
  return await Performance.findOne({
    where: {
      employee_id: employeeId,
      review_period_start: periodStart,
      review_period_end: periodEnd,
    },
  });
};

export const updatePerformanceReview = async (reviewId, data) => {
  return await Performance.update(data, { where: { id: reviewId } });
};

// Training Management
export const createTraining = async (orgId, data) => {
  return await Training.create({
    organization_id: orgId,
    ...data,
  });
};

export const enrollEmployeeInTraining = async (employeeId, trainingId) => {
  return await EmployeeTraining.create({
    employee_id: employeeId,
    training_id: trainingId,
  });
};

export const completeTraining = async (enrollmentId, score, completionDate) => {
  return await EmployeeTraining.update(
    {
      status: 'completed',
      score,
      completion_date: completionDate,
    },
    { where: { id: enrollmentId } }
  );
};

// HR Statistics
export const getHRStats = async (orgId) => {
  const totalEmployees = await Employee.count({
    where: { organization_id: orgId, status: 'active' },
  });

  const totalDepartments = await Department.count({
    where: { organization_id: orgId, is_active: true },
  });

  const pendingLeaves = await Leave.count({
    where: { organization_id: orgId, status: 'pending' },
  });

  const todayAttendance = await Attendance.count({
    where: {
      organization_id: orgId,
      attendance_date: new Date(),
      status: 'present',
    },
  });

  return {
    total_employees: totalEmployees,
    total_departments: totalDepartments,
    pending_leaves: pendingLeaves,
    today_attendance: todayAttendance,
  };
};

export default {
  createEmployee, getEmployeeById, getAllEmployees, updateEmployee,
  markAttendance, getAttendanceByEmployee, getAttendanceSummary,
  applyLeave, getLeavesByEmployee, approveLeave, rejectLeave, getPendingLeaves,
  createSalarySlip, getSalarySlips, processSalary,
  createPerformanceReview, getPerformanceReview, updatePerformanceReview,
  createTraining, enrollEmployeeInTraining, completeTraining,
  getHRStats,
};
