import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Banquet = sequelize.define('Banquet', {
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
  event_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  event_type: {
    type: DataTypes.ENUM('Wedding', 'Corporate', 'Birthday', 'Anniversary', 'Conference', 'Social', 'Other'),
    allowNull: false,
  },
  event_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  event_time: {
    type: DataTypes.TIME,
    allowNull: false,
  },
  expected_duration: {
    type: DataTypes.INTEGER,
    comment: 'in minutes',
  },
  expected_guests: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  confirmed_guests: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  location: {
    type: DataTypes.STRING,
  },
  description: {
    type: DataTypes.TEXT,
  },
  theme: {
    type: DataTypes.STRING,
  },
  status: {
    type: DataTypes.ENUM('enquiry', 'proposed', 'confirmed', 'in_progress', 'completed', 'cancelled'),
    defaultValue: 'enquiry',
  },
  booking_date: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  contact_person: {
    type: DataTypes.STRING,
  },
  contact_phone: {
    type: DataTypes.STRING,
  },
  contact_email: {
    type: DataTypes.STRING,
  },
  special_requirements: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'banquets',
});

export default Banquet;
