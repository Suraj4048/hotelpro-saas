import Joi from 'joi';

export const validateToggleModule = (data) => {
  const schema = Joi.object({
    moduleName: Joi.string().required(),
    enable: Joi.boolean().required(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default { validateToggleModule };
