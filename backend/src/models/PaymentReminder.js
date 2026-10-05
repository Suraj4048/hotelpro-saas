import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const PaymentReminder = sequelize.define('PaymentReminder', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  invoice_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'invoices', key: 'id' },
  },
  reminder_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  reminder_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  is_sent: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  reminder_method: {
    type: DataTypes.ENUM('email', 'sms', 'whatsapp'),
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'payment_reminders',
});

export default PaymentReminder;
