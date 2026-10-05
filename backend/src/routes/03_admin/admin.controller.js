import * as adminService from './admin.service.js';

export const getAllPlans = async (req, res) => {
  try {
    const plans = await adminService.getAllPlans();
    return res.json({ success: true, data: plans });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getAllClients = async (req, res) => {
  try {
    const { status, search } = req.query;
    const clients = await adminService.getAllClients({ status, search });
    return res.json({ success: true, data: clients, count: clients.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getClientById = async (req, res) => {
  try {
    const { clientId } = req.params;
    const client = await adminService.getClientById(clientId);
    if (!client) return res.status(404).json({ success: false, error: 'Client not found' });
    return res.json({ success: true, data: client });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const createClientSubscription = async (req, res) => {
  try {
    const { clientId } = req.params;
    const { planId, billingEmail } = req.body;
    if (!planId) return res.status(400).json({ success: false, error: 'planId required' });
    const subscription = await adminService.createClientSubscription(clientId, planId, billingEmail);
    return res.status(201).json({ success: true, data: subscription });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getAdminDashboard = async (req, res) => {
  try {
    const dashboard = await adminService.getAdminDashboard();
    return res.json({ success: true, data: dashboard });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export default {
  getAllPlans, getAllClients, getClientById, createClientSubscription, getAdminDashboard,
};
