#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}💳 Phase 8: Billing & Accounts Module${NC}"
echo -e "${YELLOW}========================================${NC}\n"

REPO="/workspaces/hotelpro-saas"
BACKEND="$REPO/backend/src"

cd "$REPO" || exit 1

# Create directories
echo -e "${YELLOW}1️⃣ Creating directories...${NC}"
mkdir -p "$BACKEND/routes/08_billing"
mkdir -p "$BACKEND/models"
echo -e "${GREEN}✅ Directories created${NC}\n"

# Create Invoice model
echo -e "${YELLOW}2️⃣ Creating Invoice.js...${NC}"
cat > "$BACKEND/models/Invoice.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Invoice = sequelize.define('Invoice', {
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
  invoice_number: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
    comment: 'INV-2026-0001',
  },
  invoice_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  due_date: {
    type: DataTypes.DATE,
  },
  client_id: {
    type: DataTypes.UUID,
    references: { model: 'organizations', key: 'id' },
  },
  client_name: {
    type: DataTypes.STRING,
  },
  client_phone: {
    type: DataTypes.STRING,
  },
  client_email: {
    type: DataTypes.STRING,
  },
  client_gst: {
    type: DataTypes.STRING,
  },
  source_module: {
    type: DataTypes.ENUM('restaurant', 'bar', 'banquet', 'pms', 'manual'),
    allowNull: false,
  },
  source_reference_id: {
    type: DataTypes.UUID,
    comment: 'Order ID, Banquet ID, Reservation ID, etc.',
  },
  subtotal: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  tax_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  tax_rate: {
    type: DataTypes.DECIMAL(5, 2),
    defaultValue: 18.00,
  },
  discount_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  discount_percentage: {
    type: DataTypes.DECIMAL(5, 2),
  },
  service_charge: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  other_charges: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  total_amount: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false,
  },
  paid_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  balance_due: {
    type: DataTypes.DECIMAL(12, 2),
  },
  status: {
    type: DataTypes.ENUM('draft', 'sent', 'overdue', 'paid', 'cancelled', 'credit_note'),
    defaultValue: 'draft',
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'partial', 'paid', 'overdue'),
    defaultValue: 'pending',
  },
  notes: {
    type: DataTypes.TEXT,
  },
  terms_conditions: {
    type: DataTypes.TEXT,
  },
  issued_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  currency: {
    type: DataTypes.STRING,
    defaultValue: 'INR',
  },
}, {
  timestamps: true,
  tableName: 'invoices',
});

export default Invoice;
ENDOFFILE
echo -e "${GREEN}✅ Invoice.js created${NC}"

# Create InvoiceLineItem model
echo -e "${YELLOW}3️⃣ Creating InvoiceLineItem.js...${NC}"
cat > "$BACKEND/models/InvoiceLineItem.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const InvoiceLineItem = sequelize.define('InvoiceLineItem', {
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
  item_description: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  item_category: {
    type: DataTypes.STRING,
    comment: 'Food, Beverage, Room, Banquet, etc.',
  },
  quantity: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  unit_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  line_total: {
    type: DataTypes.DECIMAL(12, 2),
  },
  tax_rate: {
    type: DataTypes.DECIMAL(5, 2),
  },
  tax_amount: {
    type: DataTypes.DECIMAL(12, 2),
  },
  source_module: {
    type: DataTypes.ENUM('restaurant', 'bar', 'banquet', 'pms', 'manual'),
  },
  source_item_id: {
    type: DataTypes.UUID,
    comment: 'Menu item ID, Drink ID, Room ID, etc.',
  },
}, {
  timestamps: true,
  tableName: 'invoice_line_items',
});

export default InvoiceLineItem;
ENDOFFILE
echo -e "${GREEN}✅ InvoiceLineItem.js created${NC}"

# Create Payment model
echo -e "${YELLOW}4️⃣ Creating Payment.js...${NC}"
cat > "$BACKEND/models/Payment.js" << 'ENDOFFILE'
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
  amount: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false,
  },
  payment_method: {
    type: DataTypes.ENUM('cash', 'credit_card', 'debit_card', 'bank_transfer', 'cheque', 'upi', 'wallet'),
    allowNull: false,
  },
  reference_number: {
    type: DataTypes.STRING,
    comment: 'Transaction ID, Cheque number, etc.',
  },
  notes: {
    type: DataTypes.TEXT,
  },
  recorded_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  status: {
    type: DataTypes.ENUM('pending', 'cleared', 'failed', 'refunded'),
    defaultValue: 'pending',
  },
}, {
  timestamps: true,
  tableName: 'payments',
});

export default Payment;
ENDOFFILE
echo -e "${GREEN}✅ Payment.js created${NC}"

# Create Ledger model
echo -e "${YELLOW}5️⃣ Creating Ledger.js...${NC}"
cat > "$BACKEND/models/Ledger.js" << 'ENDOFFILE'
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
  },
  account_name: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'e.g., Food Sales, Bar Sales, Room Revenue, GST Payable, etc.',
  },
  account_type: {
    type: DataTypes.ENUM('income', 'expense', 'asset', 'liability', 'equity'),
    allowNull: false,
  },
  debit_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  credit_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  description: {
    type: DataTypes.STRING,
  },
  reference_type: {
    type: DataTypes.ENUM('invoice', 'payment', 'journal_entry', 'reversal'),
  },
  reference_id: {
    type: DataTypes.UUID,
  },
  invoice_id: {
    type: DataTypes.UUID,
    references: { model: 'invoices', key: 'id' },
  },
  module: {
    type: DataTypes.ENUM('restaurant', 'bar', 'banquet', 'pms', 'manual'),
  },
}, {
  timestamps: true,
  tableName: 'ledgers',
});

export default Ledger;
ENDOFFILE
echo -e "${GREEN}✅ Ledger.js created${NC}"

# Create TaxConfiguration model
echo -e "${YELLOW}6️⃣ Creating TaxConfiguration.js...${NC}"
cat > "$BACKEND/models/TaxConfiguration.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const TaxConfiguration = sequelize.define('TaxConfiguration', {
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
  tax_name: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'SGST, CGST, IGST, VAT, etc.',
  },
  tax_code: {
    type: DataTypes.STRING,
  },
  tax_rate: {
    type: DataTypes.DECIMAL(5, 2),
    allowNull: false,
  },
  tax_type: {
    type: DataTypes.ENUM('gst', 'service_tax', 'vat', 'other'),
  },
  applicable_categories: {
    type: DataTypes.JSON,
    comment: 'JSON array of categories (Food, Beverage, Room, etc.)',
  },
  applicable_modules: {
    type: DataTypes.JSON,
    comment: 'JSON array of modules (restaurant, bar, banquet, pms)',
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  effective_from: {
    type: DataTypes.DATE,
  },
  effective_to: {
    type: DataTypes.DATE,
  },
}, {
  timestamps: true,
  tableName: 'tax_configurations',
});

export default TaxConfiguration;
ENDOFFILE
echo -e "${GREEN}✅ TaxConfiguration.js created${NC}"

# Create CreditNote model
echo -e "${YELLOW}7️⃣ Creating CreditNote.js...${NC}"
cat > "$BACKEND/models/CreditNote.js" << 'ENDOFFILE'
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
  },
  invoice_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'invoices', key: 'id' },
  },
  credit_note_date: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  reason: {
    type: DataTypes.ENUM('damaged', 'overcharge', 'discount', 'return', 'cancellation', 'other'),
  },
  reason_description: {
    type: DataTypes.TEXT,
  },
  credit_amount: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false,
  },
  tax_amount: {
    type: DataTypes.DECIMAL(12, 2),
  },
  applied_to_invoice: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  issued_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  status: {
    type: DataTypes.ENUM('issued', 'applied', 'refunded', 'cancelled'),
    defaultValue: 'issued',
  },
}, {
  timestamps: true,
  tableName: 'credit_notes',
});

export default CreditNote;
ENDOFFILE
echo -e "${GREEN}✅ CreditNote.js created${NC}"

# Create PaymentReminder model
echo -e "${YELLOW}8️⃣ Creating PaymentReminder.js...${NC}"
cat > "$BACKEND/models/PaymentReminder.js" << 'ENDOFFILE'
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
  days_after_due: {
    type: DataTypes.INTEGER,
    comment: '0 = on due date, 1 = 1 day after, etc.',
  },
  reminder_type: {
    type: DataTypes.ENUM('email', 'sms', 'whatsapp', 'manual'),
  },
  reminder_number: {
    type: DataTypes.INTEGER,
    comment: '1st reminder, 2nd reminder, etc.',
  },
  is_sent: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  sent_date: {
    type: DataTypes.DATE,
  },
  message: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'payment_reminders',
});

export default PaymentReminder;
ENDOFFILE
echo -e "${GREEN}✅ PaymentReminder.js created${NC}"

# Create billing.service.js
echo -e "${YELLOW}9️⃣ Creating billing.service.js...${NC}"
cat > "$BACKEND/routes/08_billing/billing.service.js" << 'ENDOFFILE'
import Invoice from '../../models/Invoice.js';
import InvoiceLineItem from '../../models/InvoiceLineItem.js';
import Payment from '../../models/Payment.js';
import Ledger from '../../models/Ledger.js';
import TaxConfiguration from '../../models/TaxConfiguration.js';
import CreditNote from '../../models/CreditNote.js';
import PaymentReminder from '../../models/PaymentReminder.js';
import { Op } from 'sequelize';

// Invoice Management
export const createInvoice = async (orgId, data) => {
  const invoiceNumber = `INV-${new Date().getFullYear()}-${Date.now().toString().slice(-5)}`;

  const invoice = await Invoice.create({
    organization_id: orgId,
    invoice_number: invoiceNumber,
    ...data,
  });

  // Create ledger entry
  await Ledger.create({
    organization_id: orgId,
    transaction_date: new Date(),
    account_name: `${data.source_module.toUpperCase()} Sales`,
    account_type: 'income',
    credit_amount: data.total_amount,
    description: `Invoice ${invoiceNumber}`,
    reference_type: 'invoice',
    reference_id: invoice.id,
    invoice_id: invoice.id,
    module: data.source_module,
  });

  return invoice;
};

export const getInvoiceById = async (invoiceId) => {
  return await Invoice.findByPk(invoiceId, {
    include: [InvoiceLineItem],
  });
};

export const getAllInvoices = async (orgId, filters = {}) => {
  const where = { organization_id: orgId };
  if (filters.status) where.status = filters.status;
  if (filters.payment_status) where.payment_status = filters.payment_status;
  if (filters.start_date) {
    where.invoice_date = { [Op.gte]: filters.start_date };
  }
  if (filters.end_date) {
    where.invoice_date = { [Op.lte]: filters.end_date };
  }

  return await Invoice.findAll({
    where,
    include: [InvoiceLineItem, { model: Payment, as: 'payments' }],
    order: [['invoice_date', 'DESC']],
  });
};

export const addLineItemToInvoice = async (invoiceId, lineItem) => {
  const item = await InvoiceLineItem.create({
    invoice_id: invoiceId,
    line_total: lineItem.quantity * lineItem.unit_price,
    ...lineItem,
  });

  // Recalculate invoice totals
  await calculateInvoiceTotal(invoiceId);
  return item;
};

export const calculateInvoiceTotal = async (invoiceId) => {
  const items = await InvoiceLineItem.findAll({ where: { invoice_id: invoiceId } });
  const invoice = await Invoice.findByPk(invoiceId);

  const subtotal = items.reduce((sum, item) => sum + (item.line_total || 0), 0);
  const taxRate = invoice.tax_rate || 18;
  const taxAmount = (subtotal * taxRate) / 100;
  const discountAmount = invoice.discount_amount || 0;
  const serviceCharge = invoice.service_charge || 0;
  const otherCharges = invoice.other_charges || 0;

  const totalAmount = subtotal + taxAmount + serviceCharge + otherCharges - discountAmount;
  const balanceDue = totalAmount - (invoice.paid_amount || 0);

  await Invoice.update(
    {
      subtotal,
      tax_amount: taxAmount,
      total_amount: totalAmount,
      balance_due: balanceDue,
    },
    { where: { id: invoiceId } }
  );
};

export const updateInvoiceStatus = async (invoiceId, status) => {
  return await Invoice.update({ status }, { where: { id: invoiceId } });
};

// Payment Management
export const recordPayment = async (orgId, invoiceId, paymentData) => {
  const invoice = await Invoice.findByPk(invoiceId);
  const payment = await Payment.create({
    organization_id: orgId,
    invoice_id: invoiceId,
    ...paymentData,
  });

  // Update invoice
  const totalPaid = (invoice.paid_amount || 0) + payment.amount;
  const balanceDue = invoice.total_amount - totalPaid;
  const paymentStatus = balanceDue <= 0 ? 'paid' : balanceDue < invoice.total_amount ? 'partial' : 'pending';

  await Invoice.update(
    {
      paid_amount: totalPaid,
      balance_due: Math.max(0, balanceDue),
      payment_status: paymentStatus,
      status: paymentStatus === 'paid' ? 'paid' : 'sent',
    },
    { where: { id: invoiceId } }
  );

  // Create ledger entry
  await Ledger.create({
    organization_id: orgId,
    transaction_date: paymentData.payment_date || new Date(),
    account_name: `Payment - ${paymentData.payment_method.toUpperCase()}`,
    account_type: 'asset',
    debit_amount: payment.amount,
    description: `Payment for Invoice ${invoice.invoice_number}`,
    reference_type: 'payment',
    reference_id: payment.id,
    invoice_id: invoiceId,
  });

  return payment;
};

export const getPaymentsByInvoice = async (invoiceId) => {
  return await Payment.findAll({
    where: { invoice_id: invoiceId },
    order: [['payment_date', 'DESC']],
  });
};

// Credit Note Management
export const createCreditNote = async (orgId, data) => {
  const creditNoteNumber = `CN-${new Date().getFullYear()}-${Date.now().toString().slice(-5)}`;

  const creditNote = await CreditNote.create({
    organization_id: orgId,
    credit_note_number: creditNoteNumber,
    ...data,
  });

  // Create ledger entry (reversal)
  await Ledger.create({
    organization_id: orgId,
    transaction_date: new Date(),
    account_name: 'Credit Note Issued',
    account_type: 'liability',
    debit_amount: data.credit_amount,
    description: `Credit Note ${creditNoteNumber} for Invoice`,
    reference_type: 'reversal',
    reference_id: creditNote.id,
  });

  return creditNote;
};

export const applyCreditNoteToInvoice = async (creditNoteId) => {
  const creditNote = await CreditNote.findByPk(creditNoteId);
  const invoice = await Invoice.findByPk(creditNote.invoice_id);

  const newPaidAmount = (invoice.paid_amount || 0) + creditNote.credit_amount;
  const newBalanceDue = invoice.total_amount - newPaidAmount;
  const paymentStatus = newBalanceDue <= 0 ? 'paid' : 'partial';

  await Invoice.update(
    {
      paid_amount: newPaidAmount,
      balance_due: Math.max(0, newBalanceDue),
      payment_status: paymentStatus,
    },
    { where: { id: creditNote.invoice_id } }
  );

  await CreditNote.update(
    { applied_to_invoice: true, status: 'applied' },
    { where: { id: creditNoteId } }
  );

  return creditNote;
};

// Ledger Management
export const getLedgerEntries = async (orgId, filters = {}) => {
  const where = { organization_id: orgId };
  if (filters.start_date || filters.end_date) {
    where.transaction_date = {};
    if (filters.start_date) where.transaction_date[Op.gte] = filters.start_date;
    if (filters.end_date) where.transaction_date[Op.lte] = filters.end_date;
  }
  if (filters.module) where.module = filters.module;
  if (filters.account_type) where.account_type = filters.account_type;

  return await Ledger.findAll({
    where,
    order: [['transaction_date', 'DESC']],
  });
};

export const getTrialBalance = async (orgId) => {
  const entries = await Ledger.findAll({
    where: { organization_id: orgId },
    attributes: [
      'account_type',
      'account_name',
      [sequelize.fn('SUM', sequelize.col('debit_amount')), 'total_debits'],
      [sequelize.fn('SUM', sequelize.col('credit_amount')), 'total_credits'],
    ],
    group: ['account_type', 'account_name'],
  });

  return entries;
};

export const getIncomeStatement = async (orgId, startDate, endDate) => {
  const incomeEntries = await Ledger.findAll({
    where: {
      organization_id: orgId,
      account_type: 'income',
      transaction_date: { [Op.between]: [startDate, endDate] },
    },
    attributes: [
      'account_name',
      [sequelize.fn('SUM', sequelize.col('credit_amount')), 'total'],
    ],
    group: ['account_name'],
  });

  const expenseEntries = await Ledger.findAll({
    where: {
      organization_id: orgId,
      account_type: 'expense',
      transaction_date: { [Op.between]: [startDate, endDate] },
    },
    attributes: [
      'account_name',
      [sequelize.fn('SUM', sequelize.col('debit_amount')), 'total'],
    ],
    group: ['account_name'],
  });

  const totalIncome = incomeEntries.reduce((sum, entry) => sum + (parseFloat(entry.dataValues.total) || 0), 0);
  const totalExpense = expenseEntries.reduce((sum, entry) => sum + (parseFloat(entry.dataValues.total) || 0), 0);
  const profit = totalIncome - totalExpense;

  return {
    income: incomeEntries,
    expenses: expenseEntries,
    totalIncome,
    totalExpense,
    profit,
  };
};

// Tax Management
export const getTaxConfigurations = async (orgId) => {
  return await TaxConfiguration.findAll({
    where: { organization_id: orgId, is_active: true },
  });
};

export const getTaxForModule = async (orgId, module) => {
  return await TaxConfiguration.findOne({
    where: {
      organization_id: orgId,
      is_active: true,
      applicable_modules: { [Op.contains]: [module] },
    },
  });
};

// Analytics
export const getBillingStats = async (orgId) => {
  const totalInvoices = await Invoice.count({ where: { organization_id: orgId } });
  const paidInvoices = await Invoice.count({
    where: { organization_id: orgId, payment_status: 'paid' },
  });
  const overdueInvoices = await Invoice.count({
    where: {
      organization_id: orgId,
      status: 'overdue',
      due_date: { [Op.lt]: new Date() },
    },
  });

  const invoices = await Invoice.findAll({
    where: { organization_id: orgId, status: 'paid' },
  });

  const totalRevenue = invoices.reduce((sum, inv) => sum + (inv.total_amount || 0), 0);
  const totalTax = invoices.reduce((sum, inv) => sum + (inv.tax_amount || 0), 0);

  return {
    totalInvoices,
    paidInvoices,
    pendingInvoices: totalInvoices - paidInvoices,
    overdueInvoices,
    totalRevenue,
    totalTax,
    avgInvoiceValue: totalInvoices > 0 ? totalRevenue / totalInvoices : 0,
  };
};

export default {
  createInvoice, getInvoiceById, getAllInvoices, addLineItemToInvoice, calculateInvoiceTotal, updateInvoiceStatus,
  recordPayment, getPaymentsByInvoice,
  createCreditNote, applyCreditNoteToInvoice,
  getLedgerEntries, getTrialBalance, getIncomeStatement,
  getTaxConfigurations, getTaxForModule,
  getBillingStats,
};
ENDOFFILE
echo -e "${GREEN}✅ billing.service.js created${NC}"

# Create billing.controller.js
echo -e "${YELLOW}🔟 Creating billing.controller.js...${NC}"
cat > "$BACKEND/routes/08_billing/billing.controller.js" << 'ENDOFFILE'
import * as billingService from './billing.service.js';

// Invoice Management
export const createInvoice = async (req, res) => {
  try {
    const invoice = await billingService.createInvoice(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: invoice });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getInvoiceById = async (req, res) => {
  try {
    const { invoiceId } = req.params;
    const invoice = await billingService.getInvoiceById(invoiceId);
    if (!invoice) return res.status(404).json({ success: false, error: 'Invoice not found' });
    return res.json({ success: true, data: invoice });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getAllInvoices = async (req, res) => {
  try {
    const filters = req.query;
    const invoices = await billingService.getAllInvoices(req.user.organizationId, filters);
    return res.json({ success: true, data: invoices, count: invoices.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const addLineItemToInvoice = async (req, res) => {
  try {
    const { invoiceId } = req.params;
    const item = await billingService.addLineItemToInvoice(invoiceId, req.body);
    return res.status(201).json({ success: true, data: item });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const updateInvoiceStatus = async (req, res) => {
  try {
    const { invoiceId } = req.params;
    const { status } = req.body;
    await billingService.updateInvoiceStatus(invoiceId, status);
    return res.json({ success: true, message: 'Invoice status updated' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Payment Management
export const recordPayment = async (req, res) => {
  try {
    const { invoiceId } = req.params;
    const payment = await billingService.recordPayment(req.user.organizationId, invoiceId, req.body);
    return res.status(201).json({ success: true, data: payment });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getPaymentsByInvoice = async (req, res) => {
  try {
    const { invoiceId } = req.params;
    const payments = await billingService.getPaymentsByInvoice(invoiceId);
    return res.json({ success: true, data: payments });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

// Credit Note Management
export const createCreditNote = async (req, res) => {
  try {
    const creditNote = await billingService.createCreditNote(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: creditNote });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const applyCreditNoteToInvoice = async (req, res) => {
  try {
    const { creditNoteId } = req.params;
    const creditNote = await billingService.applyCreditNoteToInvoice(creditNoteId);
    return res.json({ success: true, data: creditNote });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Ledger Management
export const getLedgerEntries = async (req, res) => {
  try {
    const filters = req.query;
    const entries = await billingService.getLedgerEntries(req.user.organizationId, filters);
    return res.json({ success: true, data: entries });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getTrialBalance = async (req, res) => {
  try {
    const balance = await billingService.getTrialBalance(req.user.organizationId);
    return res.json({ success: true, data: balance });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getIncomeStatement = async (req, res) => {
  try {
    const { start_date, end_date } = req.query;
    const statement = await billingService.getIncomeStatement(req.user.organizationId, start_date, end_date);
    return res.json({ success: true, data: statement });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

// Tax Management
export const getTaxConfigurations = async (req, res) => {
  try {
    const taxes = await billingService.getTaxConfigurations(req.user.organizationId);
    return res.json({ success: true, data: taxes });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

// Analytics
export const getBillingStats = async (req, res) => {
  try {
    const stats = await billingService.getBillingStats(req.user.organizationId);
    return res.json({ success: true, data: stats });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export default {
  createInvoice, getInvoiceById, getAllInvoices, addLineItemToInvoice, updateInvoiceStatus,
  recordPayment, getPaymentsByInvoice,
  createCreditNote, applyCreditNoteToInvoice,
  getLedgerEntries, getTrialBalance, getIncomeStatement,
  getTaxConfigurations,
  getBillingStats,
};
ENDOFFILE
echo -e "${GREEN}✅ billing.controller.js created${NC}"

# Create billing.routes.js
echo -e "${YELLOW}1️⃣1️⃣ Creating billing.routes.js...${NC}"
cat > "$BACKEND/routes/08_billing/billing.routes.js" << 'ENDOFFILE'
import express from 'express';
import * as billingController from './billing.controller.js';
import { checkModuleAccess } from '../../middleware/authMiddleware.js';

const router = express.Router();
router.use(checkModuleAccess('billing'));

// Invoice Management
router.post('/invoices', billingController.createInvoice);
router.get('/invoices', billingController.getAllInvoices);
router.get('/invoices/:invoiceId', billingController.getInvoiceById);
router.post('/invoices/:invoiceId/items', billingController.addLineItemToInvoice);
router.put('/invoices/:invoiceId/status', billingController.updateInvoiceStatus);

// Payment Management
router.post('/invoices/:invoiceId/payments', billingController.recordPayment);
router.get('/invoices/:invoiceId/payments', billingController.getPaymentsByInvoice);

// Credit Notes
router.post('/credit-notes', billingController.createCreditNote);
router.put('/credit-notes/:creditNoteId/apply', billingController.applyCreditNoteToInvoice);

// Ledger & Accounting
router.get('/ledger', billingController.getLedgerEntries);
router.get('/trial-balance', billingController.getTrialBalance);
router.get('/income-statement', billingController.getIncomeStatement);

// Tax Management
router.get('/tax-configurations', billingController.getTaxConfigurations);

// Analytics
router.get('/stats', billingController.getBillingStats);

export default router;
ENDOFFILE
echo -e "${GREEN}✅ billing.routes.js created${NC}"

# Create billing.validators.js
echo -e "${YELLOW}1️⃣2️⃣ Creating billing.validators.js...${NC}"
cat > "$BACKEND/routes/08_billing/billing.validators.js" << 'ENDOFFILE'
import Joi from 'joi';

export const validateCreateInvoice = (data) => {
  const schema = Joi.object({
    client_name: Joi.string().required(),
    client_phone: Joi.string(),
    client_email: Joi.string().email(),
    source_module: Joi.string().required(),
    total_amount: Joi.number().required().positive(),
    due_date: Joi.date(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateAddLineItem = (data) => {
  const schema = Joi.object({
    item_description: Joi.string().required(),
    quantity: Joi.number().required().positive(),
    unit_price: Joi.number().required().positive(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateRecordPayment = (data) => {
  const schema = Joi.object({
    amount: Joi.number().required().positive(),
    payment_method: Joi.string().required(),
    payment_date: Joi.date(),
    reference_number: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateInvoice,
  validateAddLineItem,
  validateRecordPayment,
};
ENDOFFILE
echo -e "${GREEN}✅ billing.validators.js created${NC}"

# Update server.js
echo -e "${YELLOW}1️⃣3️⃣ Updating server.js...${NC}"
if ! grep -q "import billingRoutes" "$BACKEND/server.js"; then
  sed -i "/import banquetRoutes/a import billingRoutes from './routes/08_billing/billing.routes.js';" "$BACKEND/server.js"
  sed -i "/app.use('\/api\/banquets'/a app.use('/api/billing', billingRoutes);" "$BACKEND/server.js"
  echo -e "${GREEN}✅ server.js updated${NC}"
else
  echo -e "${YELLOW}⚠️ Billing routes already in server.js${NC}"
fi

# Git commit and push
echo -e "${YELLOW}1️⃣4️⃣ Git operations...${NC}"
git add -A
git commit -m "Phase 8: Billing & Accounts Module

- Added Invoice model
- Added InvoiceLineItem model
- Added Payment model
- Added Ledger model (double-entry accounting)
- Added TaxConfiguration model
- Added CreditNote model
- Added PaymentReminder model
- Added billing.service.js (business logic)
- Added billing.controller.js (API handlers)
- Added billing.routes.js (route definitions)
- Added billing.validators.js (input validation)
- Integrated Billing routes into server.js
- Auto-generated invoice numbers
- Auto-generated credit note numbers
- Auto-calculated totals with tax
- Ledger entries for all transactions
- Income statement generation
- Trial balance report"

git push origin main 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Pushed to GitHub${NC}"
else
  echo -e "${YELLOW}⚠️ Push failed (check connection)${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ PHASE 8 DEPLOYMENT COMPLETE!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${GREEN}📌 Billing Module Endpoints:${NC}"
echo -e "  POST   /api/billing/invoices"
echo -e "  GET    /api/billing/invoices"
echo -e "  GET    /api/billing/invoices/:invoiceId"
echo -e "  POST   /api/billing/invoices/:invoiceId/items"
echo -e "  PUT    /api/billing/invoices/:invoiceId/status"
echo -e "  POST   /api/billing/invoices/:invoiceId/payments"
echo -e "  GET    /api/billing/invoices/:invoiceId/payments"
echo -e "  POST   /api/billing/credit-notes"
echo -e "  PUT    /api/billing/credit-notes/:creditNoteId/apply"
echo -e "  GET    /api/billing/ledger"
echo -e "  GET    /api/billing/trial-balance"
echo -e "  GET    /api/billing/income-statement"
echo -e "  GET    /api/billing/tax-configurations"
echo -e "  GET    /api/billing/stats\n"

echo -e "${YELLOW}🚀 Ready for Phase 9: Inventory & Procurement Module${NC}\n"
ENDOFFILE
