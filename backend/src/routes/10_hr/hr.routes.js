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
