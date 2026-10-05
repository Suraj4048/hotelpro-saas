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
