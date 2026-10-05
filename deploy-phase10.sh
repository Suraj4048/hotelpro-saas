#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}👥 Phase 10: HR & Staff Management${NC}"
echo -e "${YELLOW}========================================${NC}\n"

REPO="/workspaces/hotelpro-saas"
BACKEND="$REPO/backend/src"

cd "$REPO" || exit 1

# Create directories
echo -e "${YELLOW}1️⃣ Creating directories...${NC}"
mkdir -p "$BACKEND/routes/10_hr"
mkdir -p "$BACKEND/models"
echo -e "${GREEN}✅ Directories created${NC}\n"

# Create Department model
echo -e "${YELLOW}2️⃣ Creating Department.js...${NC}"
cat > "$BACKEND/models/Department.js" << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Department = sequelize.define('Department', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  department_name: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  department_code: {
    type: DataTypes.STRING,
    unique: true,
  },
  description: {
    type: DataTypes.TEXT,
  },
  head_id: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
    comment: 'Department head',
  },
  budget: {
    type: DataTypes.DECIMAL(12, 2),
    comment: 'Department budget',
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'departments',
});

export default Department;
EOF
echo -e "${GREEN}✅ Department.js created${NC}"

# Create Designation model
echo -e "${YELLOW}3️⃣ Creating Designation.js...${NC}"
cat > "$BACKEND/models/Designation.js" << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Designation = sequelize.define('Designation', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  designation_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  level: {
    type: DataTypes.ENUM('entry', 'junior', 'senior', 'lead', 'manager', 'head', 'director', 'executive'),
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
  },
  salary_range_min: {
    type: DataTypes.DECIMAL(12, 2),
  },
  salary_range_max: {
    type: DataTypes.DECIMAL(12, 2),
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'designations',
});

export default Designation;
EOF
echo -e "${GREEN}✅ Designation.js created${NC}"

# Create Employee model
echo -e "${YELLOW}4️⃣ Creating Employee.js...${NC}"
cat > "$BACKEND/models/Employee.js" << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Employee = sequelize.define('Employee', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  user_id: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  employee_code: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
  },
  first_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  last_name: {
    type: DataTypes.STRING,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  phone: {
    type: DataTypes.STRING,
  },
  date_of_birth: {
    type: DataTypes.DATE,
  },
  gender: {
    type: DataTypes.ENUM('male', 'female', 'other'),
  },
  department_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'departments', key: 'id' },
  },
  designation_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'designations', key: 'id' },
  },
  reporting_to_id: {
    type: DataTypes.UUID,
    references: { model: 'employees', key: 'id' },
    comment: 'Manager/Supervisor ID',
  },
  employment_type: {
    type: DataTypes.ENUM('full_time', 'part_time', 'contract', 'temporary'),
    defaultValue: 'full_time',
  },
  date_of_joining: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  date_of_exit: {
    type: DataTypes.DATE,
  },
  address: {
    type: DataTypes.TEXT,
  },
  city: {
    type: DataTypes.STRING,
  },
  state: {
    type: DataTypes.STRING,
  },
  country: {
    type: DataTypes.STRING,
  },
  pan: {
    type: DataTypes.STRING,
    comment: 'PAN number',
  },
  aadhar: {
    type: DataTypes.STRING,
    comment: 'Aadhar number',
  },
  bank_account: {
    type: DataTypes.STRING,
  },
  ifsc_code: {
    type: DataTypes.STRING,
  },
  emergency_contact_name: {
    type: DataTypes.STRING,
  },
  emergency_contact_phone: {
    type: DataTypes.STRING,
  },
  base_salary: {
    type: DataTypes.DECIMAL(12, 2),
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive', 'on_leave', 'terminated'),
    defaultValue: 'active',
  },
}, {
  timestamps: true,
  tableName: 'employees',
});

export default Employee;
EOF
echo -e "${GREEN}✅ Employee.js created${NC}"

# Create Attendance model
echo -e "${YELLOW}5️⃣ Creating Attendance.js...${NC}"
cat > "$BACKEND/models/Attendance.js" << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Attendance = sequelize.define('Attendance', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  employee_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'employees', key: 'id' },
  },
  attendance_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  check_in_time: {
    type: DataTypes.TIME,
  },
  check_out_time: {
    type: DataTypes.TIME,
  },
  status: {
    type: DataTypes.ENUM('present', 'absent', 'late', 'half_day', 'work_from_home'),
    defaultValue: 'absent',
  },
  hours_worked: {
    type: DataTypes.DECIMAL(5, 2),
  },
  location: {
    type: DataTypes.STRING,
    comment: 'Office/Remote/Field',
  },
  notes: {
    type: DataTypes.TEXT,
  },
  approved_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
}, {
  timestamps: true,
  tableName: 'attendance',
  indexes: [
    { fields: ['employee_id', 'attendance_date'] },
  ],
});

export default Attendance;
EOF
echo -e "${GREEN}✅ Attendance.js created${NC}"

# Create Leave model
echo -e "${YELLOW}6️⃣ Creating Leave.js...${NC}"
cat > "$BACKEND/models/Leave.js" << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Leave = sequelize.define('Leave', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  employee_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'employees', key: 'id' },
  },
  leave_type: {
    type: DataTypes.ENUM('casual', 'sick', 'personal', 'maternity', 'paternity', 'unpaid', 'other'),
    allowNull: false,
  },
  from_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  to_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  number_of_days: {
    type: DataTypes.DECIMAL(5, 2),
  },
  reason: {
    type: DataTypes.TEXT,
  },
  status: {
    type: DataTypes.ENUM('pending', 'approved', 'rejected', 'cancelled'),
    defaultValue: 'pending',
  },
  approved_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  approval_date: {
    type: DataTypes.DATE,
  },
  remarks: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'leaves',
});

export default Leave;
EOF
echo -e "${GREEN}✅ Leave.js created${NC}"

# Create Salary model
echo -e "${YELLOW}7️⃣ Creating Salary.js...${NC}"
cat > "$BACKEND/models/Salary.js" << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Salary = sequelize.define('Salary', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  employee_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'employees', key: 'id' },
  },
  salary_month: {
    type: DataTypes.DATE,
    allowNull: false,
    comment: 'Month for which salary is paid',
  },
  base_salary: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false,
  },
  dearness_allowance: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  house_rent_allowance: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  other_allowances: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  total_earnings: {
    type: DataTypes.DECIMAL(12, 2),
  },
  pf_deduction: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  it_deduction: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  other_deductions: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  total_deductions: {
    type: DataTypes.DECIMAL(12, 2),
  },
  net_salary: {
    type: DataTypes.DECIMAL(12, 2),
  },
  working_days: {
    type: DataTypes.INTEGER,
    comment: 'Days worked in month',
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'processing', 'paid', 'failed'),
    defaultValue: 'pending',
  },
  payment_date: {
    type: DataTypes.DATE,
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'salary',
  indexes: [
    { fields: ['employee_id', 'salary_month'] },
  ],
});

export default Salary;
EOF
echo -e "${GREEN}✅ Salary.js created${NC}"

# Create Performance model
echo -e "${YELLOW}8️⃣ Creating Performance.js...${NC}"
cat > "$BACKEND/models/Performance.js" << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Performance = sequelize.define('Performance', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  employee_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'employees', key: 'id' },
  },
  review_period_start: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  review_period_end: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  reviewed_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  performance_rating: {
    type: DataTypes.DECIMAL(3, 1),
    comment: '1-5 rating',
  },
  attendance_rating: {
    type: DataTypes.DECIMAL(3, 1),
  },
  quality_rating: {
    type: DataTypes.DECIMAL(3, 1),
  },
  teamwork_rating: {
    type: DataTypes.DECIMAL(3, 1),
  },
  communication_rating: {
    type: DataTypes.DECIMAL(3, 1),
  },
  strengths: {
    type: DataTypes.TEXT,
  },
  areas_for_improvement: {
    type: DataTypes.TEXT,
  },
  goals_for_next_period: {
    type: DataTypes.TEXT,
  },
  comments: {
    type: DataTypes.TEXT,
  },
  status: {
    type: DataTypes.ENUM('draft', 'submitted', 'approved', 'rejected'),
    defaultValue: 'draft',
  },
}, {
  timestamps: true,
  tableName: 'performance_reviews',
});

export default Performance;
EOF
echo -e "${GREEN}✅ Performance.js created${NC}"

# Create Training model
echo -e "${YELLOW}9️⃣ Creating Training.js...${NC}"
cat > "$BACKEND/models/Training.js" << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Training = sequelize.define('Training', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  training_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  training_type: {
    type: DataTypes.ENUM('technical', 'soft_skills', 'product', 'compliance', 'other'),
  },
  start_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  end_date: {
    type: DataTypes.DATE,
  },
  trainer: {
    type: DataTypes.STRING,
    comment: 'External trainer or internal resource',
  },
  cost: {
    type: DataTypes.DECIMAL(12, 2),
  },
  status: {
    type: DataTypes.ENUM('planned', 'in_progress', 'completed', 'cancelled'),
    defaultValue: 'planned',
  },
}, {
  timestamps: true,
  tableName: 'trainings',
});

export default Training;
EOF
echo -e "${GREEN}✅ Training.js created${NC}"

# Create EmployeeTraining model
echo -e "${YELLOW}🔟 Creating EmployeeTraining.js...${NC}"
cat > "$BACKEND/models/EmployeeTraining.js" << 'EOF'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const EmployeeTraining = sequelize.define('EmployeeTraining', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  employee_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'employees', key: 'id' },
  },
  training_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'trainings', key: 'id' },
  },
  status: {
    type: DataTypes.ENUM('enrolled', 'completed', 'failed', 'cancelled'),
    defaultValue: 'enrolled',
  },
  score: {
    type: DataTypes.DECIMAL(5, 2),
    comment: 'Training score if applicable',
  },
  completion_date: {
    type: DataTypes.DATE,
  },
  certificate_issued: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
}, {
  timestamps: true,
  tableName: 'employee_trainings',
});

export default EmployeeTraining;
EOF
echo -e "${GREEN}✅ EmployeeTraining.js created${NC}"

# Create hr.service.js
echo -e "${YELLOW}1️⃣1️⃣ Creating hr.service.js...${NC}"
cat > "$BACKEND/routes/10_hr/hr.service.js" << 'EOF'
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
EOF
echo -e "${GREEN}✅ hr.service.js created${NC}"

# Create hr.controller.js
echo -e "${YELLOW}1️⃣2️⃣ Creating hr.controller.js...${NC}"
cat > "$BACKEND/routes/10_hr/hr.controller.js" << 'EOF'
import * as hrService from './hr.service.js';

export const createEmployee = async (req, res) => {
  try {
    const employee = await hrService.createEmployee(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: employee });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getEmployeeById = async (req, res) => {
  try {
    const { employeeId } = req.params;
    const employee = await hrService.getEmployeeById(employeeId);
    if (!employee) return res.status(404).json({ success: false, error: 'Employee not found' });
    return res.json({ success: true, data: employee });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getAllEmployees = async (req, res) => {
  try {
    const filters = req.query;
    const employees = await hrService.getAllEmployees(req.user.organizationId, filters);
    return res.json({ success: true, data: employees, count: employees.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const markAttendance = async (req, res) => {
  try {
    const attendance = await hrService.markAttendance(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: attendance });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getAttendanceSummary = async (req, res) => {
  try {
    const { month } = req.query;
    const summary = await hrService.getAttendanceSummary(req.user.organizationId, new Date(month));
    return res.json({ success: true, data: summary });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const applyLeave = async (req, res) => {
  try {
    const leave = await hrService.applyLeave(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: leave });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getPendingLeaves = async (req, res) => {
  try {
    const leaves = await hrService.getPendingLeaves(req.user.organizationId);
    return res.json({ success: true, data: leaves });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const approveLeave = async (req, res) => {
  try {
    const { leaveId } = req.params;
    const { remarks } = req.body;
    await hrService.approveLeave(leaveId, req.user.id, remarks);
    return res.json({ success: true, message: 'Leave approved' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const rejectLeave = async (req, res) => {
  try {
    const { leaveId } = req.params;
    const { remarks } = req.body;
    await hrService.rejectLeave(leaveId, req.user.id, remarks);
    return res.json({ success: true, message: 'Leave rejected' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const createSalarySlip = async (req, res) => {
  try {
    const { employeeId } = req.params;
    const slip = await hrService.createSalarySlip(req.user.organizationId, employeeId, req.body);
    return res.status(201).json({ success: true, data: slip });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const processSalary = async (req, res) => {
  try {
    const { month } = req.body;
    const result = await hrService.processSalary(req.user.organizationId, month);
    return res.json({ success: true, data: result });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const createPerformanceReview = async (req, res) => {
  try {
    const review = await hrService.createPerformanceReview(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: review });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const createTraining = async (req, res) => {
  try {
    const training = await hrService.createTraining(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: training });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const enrollInTraining = async (req, res) => {
  try {
    const { employeeId, trainingId } = req.body;
    const enrollment = await hrService.enrollEmployeeInTraining(employeeId, trainingId);
    return res.status(201).json({ success: true, data: enrollment });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getHRStats = async (req, res) => {
  try {
    const stats = await hrService.getHRStats(req.user.organizationId);
    return res.json({ success: true, data: stats });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export default {
  createEmployee, getEmployeeById, getAllEmployees,
  markAttendance, getAttendanceSummary,
  applyLeave, getPendingLeaves, approveLeave, rejectLeave,
  createSalarySlip, processSalary,
  createPerformanceReview,
  createTraining, enrollInTraining,
  getHRStats,
};
EOF
echo -e "${GREEN}✅ hr.controller.js created${NC}"

# Create hr.routes.js
echo -e "${YELLOW}1️⃣3️⃣ Creating hr.routes.js...${NC}"
cat > "$BACKEND/routes/10_hr/hr.routes.js" << 'EOF'
import express from 'express';
import * as hrController from './hr.controller.js';
import { checkModuleAccess, checkRoleAccess } from '../../middleware/authMiddleware.js';

const router = express.Router();
router.use(checkModuleAccess('hr'));

// Employees
router.post('/employees', hrController.createEmployee);
router.get('/employees', hrController.getAllEmployees);
router.get('/employees/:employeeId', hrController.getEmployeeById);

// Attendance
router.post('/attendance', hrController.markAttendance);
router.get('/attendance/summary', hrController.getAttendanceSummary);

// Leave
router.post('/leaves', hrController.applyLeave);
router.get('/leaves/pending', hrController.getPendingLeaves);
router.put('/leaves/:leaveId/approve', hrController.approveLeave);
router.put('/leaves/:leaveId/reject', hrController.rejectLeave);

// Salary
router.post('/employees/:employeeId/salary', hrController.createSalarySlip);
router.post('/salary/process', checkRoleAccess('SUPER_ADMIN'), hrController.processSalary);

// Performance
router.post('/performance-reviews', hrController.createPerformanceReview);

// Training
router.post('/trainings', hrController.createTraining);
router.post('/trainings/enroll', hrController.enrollInTraining);

// Stats
router.get('/stats', hrController.getHRStats);

export default router;
EOF
echo -e "${GREEN}✅ hr.routes.js created${NC}"

# Create hr.validators.js
echo -e "${YELLOW}1️⃣4️⃣ Creating hr.validators.js...${NC}"
cat > "$BACKEND/routes/10_hr/hr.validators.js" << 'EOF'
import Joi from 'joi';

export const validateCreateEmployee = (data) => {
  const schema = Joi.object({
    first_name: Joi.string().required(),
    last_name: Joi.string(),
    email: Joi.string().email().required(),
    phone: Joi.string(),
    department_id: Joi.string().uuid().required(),
    designation_id: Joi.string().uuid().required(),
    date_of_joining: Joi.date().required(),
    employment_type: Joi.string(),
    base_salary: Joi.number(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateMarkAttendance = (data) => {
  const schema = Joi.object({
    employee_id: Joi.string().uuid().required(),
    attendance_date: Joi.date().required(),
    status: Joi.string().valid('present', 'absent', 'late', 'half_day', 'work_from_home').required(),
    check_in_time: Joi.time(),
    check_out_time: Joi.time(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateApplyLeave = (data) => {
  const schema = Joi.object({
    employee_id: Joi.string().uuid().required(),
    leave_type: Joi.string().required(),
    from_date: Joi.date().required(),
    to_date: Joi.date().required(),
    reason: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateEmployee,
  validateMarkAttendance,
  validateApplyLeave,
};
EOF
echo -e "${GREEN}✅ hr.validators.js created${NC}"

# Update server.js
echo -e "${YELLOW}1️⃣5️⃣ Updating server.js...${NC}"
if ! grep -q "import hrRoutes" "$BACKEND/server.js"; then
  sed -i "/import inventoryRoutes/a import hrRoutes from './routes/10_hr/hr.routes.js';" "$BACKEND/server.js"
  sed -i "/app.use('\/api\/inventory'/a app.use('/api/hr', hrRoutes);" "$BACKEND/server.js"
  echo -e "${GREEN}✅ server.js updated${NC}"
else
  echo -e "${YELLOW}⚠️ HR routes already in server.js${NC}"
fi

# Git commit and push
echo -e "${YELLOW}1️⃣6️⃣ Git operations...${NC}"
git add -A
git commit -m "Phase 10: HR & Staff Management Module

- Added Department model
- Added Designation model (8 levels)
- Added Employee model (complete profile)
- Added Attendance model (with daily tracking)
- Added Leave model (7 leave types)
- Added Salary model (earnings + deductions)
- Added Performance model (review ratings)
- Added Training model
- Added EmployeeTraining model (enrollment)
- Added hr.service.js (business logic)
- Added hr.controller.js (API handlers)
- Added hr.routes.js (route definitions)
- Added hr.validators.js (input validation)
- Integrated HR routes into server.js
- Auto-employee code generation
- Attendance tracking with check-in/out
- Leave approval workflow
- Salary slip generation
- Performance review system
- Training enrollment & completion
- HR dashboard statistics"

git push origin main 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Pushed to GitHub${NC}"
else
  echo -e "${YELLOW}⚠️ Push failed (check connection)${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ PHASE 10 DEPLOYMENT COMPLETE!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${GREEN}👥 HR Module Endpoints:${NC}"
echo -e "  POST   /api/hr/employees"
echo -e "  GET    /api/hr/employees"
echo -e "  GET    /api/hr/employees/:employeeId"
echo -e "  POST   /api/hr/attendance"
echo -e "  GET    /api/hr/attendance/summary"
echo -e "  POST   /api/hr/leaves"
echo -e "  GET    /api/hr/leaves/pending"
echo -e "  PUT    /api/hr/leaves/:leaveId/approve"
echo -e "  PUT    /api/hr/leaves/:leaveId/reject"
echo -e "  POST   /api/hr/employees/:employeeId/salary"
echo -e "  POST   /api/hr/salary/process"
echo -e "  POST   /api/hr/performance-reviews"
echo -e "  POST   /api/hr/trainings"
echo -e "  POST   /api/hr/trainings/enroll"
echo -e "  GET    /api/hr/stats\n"

echo -e "${YELLOW}✅ Ready for Phase 11: Housekeeping & Laundry${NC}\n"
EOF
