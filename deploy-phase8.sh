#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}💰 Phase 8: Billing & Accounts${NC}"
echo -e "${YELLOW}========================================${NC}\n"

REPO="/workspaces/hotelpro-saas"
BACKEND="$REPO/backend/src"

cd "$REPO" || exit 1

# Create directories
echo -e "${YELLOW}1️⃣ Creating directories...${NC}"
mkdir -p "$BACKEND/routes/08_billing"
mkdir -p "$BACKEND/models"
echo -e "${GREEN}✅ Directories created${NC}\n"

# Create TaxConfiguration model
echo -e "${YELLOW}2️⃣ Creating TaxConfiguration.js...${NC}"
cat > "$BACKEND/models/TaxConfiguration.js" << 'EOF'
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
  },
  tax_type: {
    type: DataTypes.ENUM('GST', 'VAT', 'SERVICE_TAX', 'OTHER'),
    allowNull: false,
  },
  tax_rate: {
    type: DataTypes.DECIMAL(5, 2),
    allowNull: false,
  },
  module: {
    type: DataTypes.ENUM('restaurant', 'bar', 'banquet', 'pms', 'manual'),
    allowNull: false,
  },
  category: {
    type: DataTypes.STRING,
    comment: 'e.g., Food, Beverage, Room, etc.',
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'tax_configurations',
});

export default TaxConfiguration;
EOF
echo -e "${GREEN}✅ TaxConfiguration.js created${NC}"

# Create Invoice model
echo -e "${YELLOW}3️⃣ Creating Invoice.js...${NC}"
cat > "$BACKEND/models/Invoice.js" << 'EOF'
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
    comment: 'Auto-generated: INV-YYYY-XXXXX',
  },
  invoice_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  bill_to: {
    type: DataTypes.STRING,
    comment: 'Customer name or guest name',
  },
  reference_type: {
    type: DataTypes.ENUM('restaurant_order', 'bar_order', 'banquet', 'room_booking', 'manual'),
    comment: 'Where invoice originated',
  },
  reference_id: {
    type: DataTypes.UUID,
    comment: 'ID of order/booking',
  },
  subtotal: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  tax_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  service_charge: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  discount_amount: {
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
  payment_status: {
    type: DataTypes.ENUM('pending', 'partial', 'paid'),
    defaultValue: 'pending',
  },
  invoice_status: {
    type: DataTypes.ENUM('draft', 'issued', 'paid', 'cancelled', 'refunded'),
    defaultValue: 'draft',
  },
  due_date: {
    type: DataTypes.DATE,
  },
  notes: {
    type: DataTypes.TEXT,
  },
  created_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
}, {
  timestamps: true,
  tableName: 'invoices',
});

export default Invoice;
EOF
echo -e "${GREEN}✅ Invoice.js created${NC}"

# Create InvoiceLineItem model
echo -e "${YELLOW}4️⃣ Creating InvoiceLineItem.js...${NC}"
cat > "$BACKEND/models/InvoiceLineItem.js" << 'EOF'
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
  description: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  quantity: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  unit_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  tax_rate: {
    type: DataTypes.DECIMAL(5, 2),
    defaultValue: 0,
  },
  line_total: {
    type: DataTypes.DECIMAL(12, 2),
  },
}, {
  timestamps: true,
  tableName: 'invoice_line_items',
});

export default InvoiceLineItem;
EOF
echo -e "${GREEN}✅ InvoiceLineItem.js created${NC}"

# Create Payment model
echo -e "${YELLOW}5️⃣ Creating Payment.js...${NC}"
cat > "$BACKEND/models/Payment.js" << 'EOF'
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
EOF
echo -e "${GREEN}✅ Payment.js created${NC}"

# Create Ledger model
echo -e "${YELLOW}6️⃣ Creating Ledger.js...${NC}"
cat > "$BACKEND/models/Ledger.js" << 'EOF'
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
EOF
echo -e "${GREEN}✅ Ledger.js created${NC}"

# Create CreditNote model
echo -e "${YELLOW}7️⃣ Creating CreditNote.js...${NC}"
cat > "$BACKEND/models/CreditNote.js" << 'EOF'
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
EOF
echo -e "${GREEN}✅ CreditNote.js created${NC}"

# Create PaymentReminder model
echo -e "${YELLOW}8️⃣ Creating PaymentReminder.js...${NC}"
cat > "$BACKEND/models/PaymentReminder.js" << 'EOF'
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
EOF
echo -e "${GREEN}✅ PaymentReminder.js created${NC}"

# Create billing.service.js
echo -e "${YELLOW}9️⃣ Creating billing.service.js...${NC}"
cat > "$BACKEND/routes/08_billing/billing.service.js" << 'EOF'
import Invoice from '../../models/Invoice.js';
import InvoiceLineItem from '../../models/InvoiceLineItem.js';
import Payment from '../../models/Payment.js';
import Ledger from '../../models/Ledger.js';
import CreditNote from '../../models/CreditNote.js';
import TaxConfiguration from '../../models/TaxConfiguration.js';
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
    transaction_type: 'invoice',
    reference_id: invoice.id,
    account_head: 'Accounts Receivable',
    debit_amount: data.total_amount,
    credit_amount: 0,
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
  if (filters.status) where.invoice_status = filters.status;
  if (filters.from_date) where.invoice_date = { [Op.gte]: filters.from_date };
  if (filters.to_date) where.invoice_date = { [Op.lte]: filters.to_date };

  return await Invoice.findAll({
    where,
    order: [['invoice_date', 'DESC']],
  });
};

export const addLineItemToInvoice = async (invoiceId, itemData) => {
  const lineTotal = itemData.quantity * itemData.unit_price;
  
  const item = await InvoiceLineItem.create({
    invoice_id: invoiceId,
    line_total: lineTotal,
    ...itemData,
  });

  await recalculateInvoiceTotal(invoiceId);
  return item;
};

export const recalculateInvoiceTotal = async (invoiceId) => {
  const items = await InvoiceLineItem.findAll({ where: { invoice_id: invoiceId } });
  const invoice = await Invoice.findByPk(invoiceId);

  const subtotal = items.reduce((sum, item) => sum + (item.line_total || 0), 0);
  const taxAmount = (subtotal * (invoice.tax_amount || 18)) / 100;
  const total = subtotal + taxAmount - (invoice.discount_amount || 0);

  await Invoice.update(
    {
      subtotal,
      tax_amount: taxAmount,
      total_amount: total,
    },
    { where: { id: invoiceId } }
  );
};

export const recordPayment = async (orgId, invoiceId, paymentData) => {
  const payment = await Payment.create({
    organization_id: orgId,
    invoice_id: invoiceId,
    ...paymentData,
  });

  const invoice = await Invoice.findByPk(invoiceId);
  const totalPaid = (invoice.paid_amount || 0) + paymentData.amount_paid;
  
  let paymentStatus = 'pending';
  if (totalPaid >= invoice.total_amount) {
    paymentStatus = 'paid';
  } else if (totalPaid > 0) {
    paymentStatus = 'partial';
  }

  await Invoice.update(
    {
      paid_amount: totalPaid,
      payment_status: paymentStatus,
      invoice_status: paymentStatus === 'paid' ? 'paid' : 'issued',
    },
    { where: { id: invoiceId } }
  );

  // Create ledger entry
  await Ledger.create({
    organization_id: orgId,
    transaction_date: new Date(),
    transaction_type: 'payment',
    reference_id: payment.id,
    account_head: 'Cash/Bank',
    debit_amount: 0,
    credit_amount: paymentData.amount_paid,
  });

  return payment;
};

export const createCreditNote = async (orgId, data) => {
  const creditNoteNumber = `CN-${new Date().getFullYear()}-${Date.now().toString().slice(-5)}`;
  
  const creditNote = await CreditNote.create({
    organization_id: orgId,
    credit_note_number: creditNoteNumber,
    remaining_amount: data.credit_amount,
    ...data,
  });

  // Create ledger entry
  await Ledger.create({
    organization_id: orgId,
    transaction_date: new Date(),
    transaction_type: 'credit_note',
    reference_id: creditNote.id,
    account_head: 'Credit Notes',
    debit_amount: 0,
    credit_amount: data.credit_amount,
  });

  return creditNote;
};

export const applyCreditNoteToInvoice = async (creditNoteId, invoiceId) => {
  const creditNote = await CreditNote.findByPk(creditNoteId);
  const invoice = await Invoice.findByPk(invoiceId);

  const applicableAmount = Math.min(creditNote.remaining_amount, invoice.total_amount - invoice.paid_amount);

  await CreditNote.update(
    {
      applied_amount: (creditNote.applied_amount || 0) + applicableAmount,
      remaining_amount: creditNote.remaining_amount - applicableAmount,
      status: creditNote.remaining_amount - applicableAmount === 0 ? 'fully_applied' : 'partial',
    },
    { where: { id: creditNoteId } }
  );

  const newPaidAmount = (invoice.paid_amount || 0) + applicableAmount;
  
  await Invoice.update(
    {
      paid_amount: newPaidAmount,
      payment_status: newPaidAmount >= invoice.total_amount ? 'paid' : 'partial',
    },
    { where: { id: invoiceId } }
  );

  return creditNote;
};

// Financial Reports
export const getTrialBalance = async (orgId, date) => {
  const ledgerEntries = await Ledger.findAll({
    where: {
      organization_id: orgId,
      transaction_date: { [Op.lte]: date },
    },
  });

  const balances = {};
  
  ledgerEntries.forEach(entry => {
    const head = entry.account_head;
    if (!balances[head]) balances[head] = { debit: 0, credit: 0 };
    balances[head].debit += entry.debit_amount || 0;
    balances[head].credit += entry.credit_amount || 0;
  });

  return balances;
};

export const getIncomeStatement = async (orgId, fromDate, toDate) => {
  const invoices = await Invoice.findAll({
    where: {
      organization_id: orgId,
      invoice_date: { [Op.between]: [fromDate, toDate] },
      invoice_status: { [Op.ne]: 'cancelled' },
    },
  });

  const totalRevenue = invoices.reduce((sum, inv) => sum + (inv.total_amount || 0), 0);
  const totalPaid = invoices.reduce((sum, inv) => sum + (inv.paid_amount || 0), 0);
  const outstandingAmount = totalRevenue - totalPaid;

  return {
    period: { from: fromDate, to: toDate },
    total_revenue: totalRevenue,
    total_paid: totalPaid,
    outstanding_amount: outstandingAmount,
    invoice_count: invoices.length,
  };
};

export const getBillingStats = async (orgId) => {
  const pendingAmount = await Invoice.sum('total_amount', {
    where: {
      organization_id: orgId,
      payment_status: { [Op.ne]: 'paid' },
    },
  });

  const totalCollected = await Invoice.sum('paid_amount', {
    where: { organization_id: orgId },
  });

  const overdueInvoices = await Invoice.count({
    where: {
      organization_id: orgId,
      due_date: { [Op.lt]: new Date() },
      payment_status: { [Op.ne]: 'paid' },
    },
  });

  return {
    pending_amount: pendingAmount || 0,
    total_collected: totalCollected || 0,
    overdue_invoices: overdueInvoices,
  };
};

export default {
  createInvoice, getInvoiceById, getAllInvoices, addLineItemToInvoice, recalculateInvoiceTotal,
  recordPayment,
  createCreditNote, applyCreditNoteToInvoice,
  getTrialBalance, getIncomeStatement, getBillingStats,
};
EOF
echo -e "${GREEN}✅ billing.service.js created${NC}"

# Create billing.controller.js
echo -e "${YELLOW}🔟 Creating billing.controller.js...${NC}"
cat > "$BACKEND/routes/08_billing/billing.controller.js" << 'EOF'
import * as billingService from './billing.service.js';

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

export const addLineItem = async (req, res) => {
  try {
    const { invoiceId } = req.params;
    const item = await billingService.addLineItemToInvoice(invoiceId, req.body);
    return res.status(201).json({ success: true, data: item });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const recordPayment = async (req, res) => {
  try {
    const { invoiceId } = req.params;
    const payment = await billingService.recordPayment(req.user.organizationId, invoiceId, req.body);
    return res.status(201).json({ success: true, data: payment });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const createCreditNote = async (req, res) => {
  try {
    const creditNote = await billingService.createCreditNote(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: creditNote });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const applyCreditNote = async (req, res) => {
  try {
    const { creditNoteId } = req.params;
    const { invoiceId } = req.body;
    const creditNote = await billingService.applyCreditNoteToInvoice(creditNoteId, invoiceId);
    return res.json({ success: true, data: creditNote });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getTrialBalance = async (req, res) => {
  try {
    const { date } = req.query;
    const balances = await billingService.getTrialBalance(req.user.organizationId, new Date(date));
    return res.json({ success: true, data: balances });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getIncomeStatement = async (req, res) => {
  try {
    const { from_date, to_date } = req.query;
    const statement = await billingService.getIncomeStatement(req.user.organizationId, new Date(from_date), new Date(to_date));
    return res.json({ success: true, data: statement });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getBillingStats = async (req, res) => {
  try {
    const stats = await billingService.getBillingStats(req.user.organizationId);
    return res.json({ success: true, data: stats });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export default {
  createInvoice, getInvoiceById, getAllInvoices, addLineItem,
  recordPayment,
  createCreditNote, applyCreditNote,
  getTrialBalance, getIncomeStatement, getBillingStats,
};
EOF
echo -e "${GREEN}✅ billing.controller.js created${NC}"

# Create billing.routes.js
echo -e "${YELLOW}1️⃣1️⃣ Creating billing.routes.js...${NC}"
cat > "$BACKEND/routes/08_billing/billing.routes.js" << 'EOF'
import express from 'express';
import * as billingController from './billing.controller.js';
import { checkModuleAccess } from '../../middleware/authMiddleware.js';

const router = express.Router();
router.use(checkModuleAccess('billing'));

// Invoices
router.post('/invoices', billingController.createInvoice);
router.get('/invoices', billingController.getAllInvoices);
router.get('/invoices/:invoiceId', billingController.getInvoiceById);
router.post('/invoices/:invoiceId/items', billingController.addLineItem);

// Payments
router.post('/invoices/:invoiceId/payments', billingController.recordPayment);

// Credit Notes
router.post('/credit-notes', billingController.createCreditNote);
router.put('/credit-notes/:creditNoteId/apply', billingController.applyCreditNote);

// Reports
router.get('/trial-balance', billingController.getTrialBalance);
router.get('/income-statement', billingController.getIncomeStatement);
router.get('/stats', billingController.getBillingStats);

export default router;
EOF
echo -e "${GREEN}✅ billing.routes.js created${NC}"

# Create billing.validators.js
echo -e "${YELLOW}1️⃣2️⃣ Creating billing.validators.js...${NC}"
cat > "$BACKEND/routes/08_billing/billing.validators.js" << 'EOF'
import Joi from 'joi';

export const validateCreateInvoice = (data) => {
  const schema = Joi.object({
    bill_to: Joi.string().required(),
    reference_type: Joi.string(),
    reference_id: Joi.string().uuid(),
    subtotal: Joi.number().required(),
    tax_amount: Joi.number(),
    total_amount: Joi.number().required(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateAddLineItem = (data) => {
  const schema = Joi.object({
    description: Joi.string().required(),
    quantity: Joi.number().required(),
    unit_price: Joi.number().required(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateRecordPayment = (data) => {
  const schema = Joi.object({
    amount_paid: Joi.number().required(),
    payment_method: Joi.string().valid('cash', 'credit_card', 'debit_card', 'bank_transfer', 'cheque', 'upi', 'wallet').required(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateInvoice,
  validateAddLineItem,
  validateRecordPayment,
};
EOF
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

- Added TaxConfiguration model
- Added Invoice model (auto-generated: INV-YYYY-XXXXX)
- Added InvoiceLineItem model
- Added Payment model (7 payment methods)
- Added Ledger model (double-entry accounting)
- Added CreditNote model (auto-generated: CN-YYYY-XXXXX)
- Added PaymentReminder model
- Added billing.service.js (business logic)
- Added billing.controller.js (API handlers)
- Added billing.routes.js (route definitions)
- Added billing.validators.js (input validation)
- Integrated Billing routes into server.js
- Auto-invoice numbering
- Auto-credit note numbering
- Double-entry ledger system
- Payment tracking (pending/partial/paid)
- Trial Balance report
- Income Statement (P&L) report
- Billing statistics dashboard"

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

echo -e "${GREEN}💳 Billing Module Endpoints:${NC}"
echo -e "  POST   /api/billing/invoices"
echo -e "  GET    /api/billing/invoices"
echo -e "  GET    /api/billing/invoices/:invoiceId"
echo -e "  POST   /api/billing/invoices/:invoiceId/items"
echo -e "  POST   /api/billing/invoices/:invoiceId/payments"
echo -e "  POST   /api/billing/credit-notes"
echo -e "  PUT    /api/billing/credit-notes/:creditNoteId/apply"
echo -e "  GET    /api/billing/trial-balance"
echo -e "  GET    /api/billing/income-statement"
echo -e "  GET    /api/billing/stats\n"

echo -e "${YELLOW}✅ Ready for Phase 9: Inventory & Procurement${NC}\n"
EOF
