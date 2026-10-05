import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BanquetTimeline = sequelize.define('BanquetTimeline', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  banquet_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'banquets', key: 'id' },
  },
  event_name: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'Welcome Drinks, Speeches, Dinner, Cake Cutting, DJ, etc.',
  },
  scheduled_time: {
    type: DataTypes.TIME,
    allowNull: false,
  },
  duration_minutes: {
    type: DataTypes.INTEGER,
  },
  assigned_staff: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  description: {
    type: DataTypes.TEXT,
  },
  status: {
    type: DataTypes.ENUM('pending', 'in_progress', 'completed', 'skipped'),
    defaultValue: 'pending',
  },
  notes: {
    type: DataTypes.TEXT,
  },
  sequence: {
    type: DataTypes.INTEGER,
    comment: 'Order of events',
  },
}, {
  timestamps: true,
  tableName: 'banquet_timelines',
});

export default BanquetTimeline;
