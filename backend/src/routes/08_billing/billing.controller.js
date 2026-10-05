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
