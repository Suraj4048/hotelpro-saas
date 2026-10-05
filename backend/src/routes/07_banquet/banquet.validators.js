import Joi from 'joi';

export const validateCreateBanquet = (data) => {
  const schema = Joi.object({
    event_name: Joi.string().required(),
    event_type: Joi.string().required(),
    event_date: Joi.date().required(),
    event_time: Joi.string().required(),
    expected_guests: Joi.number().required().min(1),
    contact_person: Joi.string(),
    contact_phone: Joi.string(),
    contact_email: Joi.string().email(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateAddGuest = (data) => {
  const schema = Joi.object({
    guest_name: Joi.string().required(),
    guest_phone: Joi.string(),
    guest_email: Joi.string().email(),
    dietary_requirements: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateAddMenuItemToBanquet = (data) => {
  const schema = Joi.object({
    item_name: Joi.string().required(),
    item_category: Joi.string().required(),
    unit_price: Joi.number().required().positive(),
    quantity: Joi.number(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCreateTable = (data) => {
  const schema = Joi.object({
    table_number: Joi.string().required(),
    seating_capacity: Joi.number().required().min(1),
    table_type: Joi.string(),
    location: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateBanquet,
  validateAddGuest,
  validateAddMenuItemToBanquet,
  validateCreateTable,
};
