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
