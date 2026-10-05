import Joi from 'joi';

export const validateCreateBarOrder = (data) => {
  const schema = Joi.object({
    bar_id: Joi.string().uuid().required(),
    counter_id: Joi.string().uuid().required(),
    number_of_guests: Joi.number(),
    notes: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateAddDrinkToOrder = (data) => {
  const schema = Joi.object({
    drink_id: Joi.string().uuid().required(),
    quantity: Joi.number().required().min(1),
    special_instructions: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCreateDrink = (data) => {
  const schema = Joi.object({
    name: Joi.string().required(),
    category: Joi.string().required(),
    price: Joi.number().required().positive(),
    alcohol_percentage: Joi.number(),
    volume: Joi.string(),
    description: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateBarOrder,
  validateAddDrinkToOrder,
  validateCreateDrink,
};
