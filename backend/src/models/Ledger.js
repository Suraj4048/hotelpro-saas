import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Ledger = sequelize.define('Ledger', {
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
  transaction_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  transaction_type: {
    type: DataTypes.ENUM('invoice', 'payment', 'credit_note', 'debit_note'),
    allowNull: false,
  },
  reference_id: {
    type: DataTypes.UUID,
    comment: 'Invoice ID, Payment ID, etc.',
  },
  account_head: {
    type: DataTypes.STRING,
    comment: 'Revenue, Accounts Receivable, etc.',
  },
  debit_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  credit_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  running_balance: {
    type: DataTypes.DECIMAL(12, 2),
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'ledger',
  indexes: [
    { fields: ['transaction_date', 'account_head'] },
  ],
});

export default Ledger;
