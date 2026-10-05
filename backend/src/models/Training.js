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
