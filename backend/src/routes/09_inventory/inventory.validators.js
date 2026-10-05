import Joi from 'joi';

export const validateCreateInventoryItem = (data) => {
  const schema = Joi.object({
    category_id: Joi.string().uuid().required(),
    item_name: Joi.string().required(),
    item_code: Joi.string(),
    unit: Joi.string().required(),
    reorder_point: Joi.number(),
    reorder_quantity: Joi.number(),
    cost_per_unit: Joi.number(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCreateVendor = (data) => {
  const schema = Joi.object({
    vendor_name: Joi.string().required(),
    contact_person: Joi.string(),
    phone: Joi.string(),
    email: Joi.string().email(),
    vendor_type: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCreatePurchaseOrder = (data) => {
  const schema = Joi.object({
    vendor_id: Joi.string().uuid().required(),
    expected_delivery_date: Joi.date(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateInventoryItem,
  validateCreateVendor,
  validateCreatePurchaseOrder,
};
