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
