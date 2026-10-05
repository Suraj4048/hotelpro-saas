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
