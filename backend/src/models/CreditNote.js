import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const CreditNote = sequelize.define('CreditNote', {
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
  credit_note_number: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
    comment: 'Auto-generated: CN-YYYY-XXXXX',
  },
  invoice_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'invoices', key: 'id' },
  },
  credit_note_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  reason: {
    type: DataTypes.ENUM('damaged', 'overcharge', 'discount', 'return', 'cancellation', 'other'),
    allowNull: false,
  },
  credit_amount: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false,
  },
  applied_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  remaining_amount: {
    type: DataTypes.DECIMAL(12, 2),
  },
  status: {
    type: DataTypes.ENUM('issued', 'partial', 'fully_applied', 'cancelled'),
    defaultValue: 'issued',
  },
  notes: {
    type: DataTypes.TEXT,
  },
  issued_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
}, {
  timestamps: true,
  tableName: 'credit_notes',
});

export default CreditNote;
