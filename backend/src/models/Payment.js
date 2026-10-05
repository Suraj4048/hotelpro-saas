import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Payment = sequelize.define('Payment', {
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
  invoice_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'invoices', key: 'id' },
  },
  payment_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  amount_paid: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false,
  },
  payment_method: {
    type: DataTypes.ENUM('cash', 'credit_card', 'debit_card', 'bank_transfer', 'cheque', 'upi', 'wallet'),
    allowNull: false,
  },
  reference_number: {
    type: DataTypes.STRING,
    comment: 'Cheque #, Transaction ID, etc.',
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'confirmed', 'failed', 'reversed'),
    defaultValue: 'pending',
  },
  notes: {
    type: DataTypes.TEXT,
  },
  received_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
}, {
  timestamps: true,
  tableName: 'payments',
});

export default Payment;
