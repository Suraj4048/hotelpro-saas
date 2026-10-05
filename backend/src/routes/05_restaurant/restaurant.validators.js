import Joi from 'joi';

export const validateCreateOrder = (data) => {
  const schema = Joi.object({
    restaurant_id: Joi.string().uuid().required(),
    table_id: Joi.string().uuid().required(),
    number_of_guests: Joi.number().required(),
    notes: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateAddOrderItem = (data) => {
  const schema = Joi.object({
    menu_item_id: Joi.string().uuid().required(),
    quantity: Joi.number().required().min(1),
    special_instructions: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCreateMenuItem = (data) => {
  const schema = Joi.object({
    name: Joi.string().required(),
    category: Joi.string().required(),
    price: Joi.number().required().positive(),
    veg: Joi.boolean(),
    preparation_time: Joi.number(),
    description: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateOrder,
  validateAddOrderItem,
  validateCreateMenuItem,
};
