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
