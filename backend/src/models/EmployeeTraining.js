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
