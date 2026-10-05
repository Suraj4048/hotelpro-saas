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
