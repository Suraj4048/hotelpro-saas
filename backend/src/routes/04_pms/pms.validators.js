import Joi from 'joi';

export const validateCreateReservation = (data) => {
  const schema = Joi.object({
    guest_name: Joi.string().required(),
    guest_email: Joi.string().email(),
    guest_phone: Joi.string(),
    room_type_id: Joi.string().uuid().required(),
    check_in_date: Joi.date().required(),
    check_out_date: Joi.date().required(),
    number_of_guests: Joi.number().required(),
    notes: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCheckIn = (data) => {
  const schema = Joi.object({
    reservation_id: Joi.string().uuid().required(),
    room_id: Joi.string().uuid().required(),
    room_condition: Joi.string(),
    key_issued: Joi.boolean(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCheckOut = (data) => {
  const schema = Joi.object({
    check_in_id: Joi.string().uuid().required(),
    room_id: Joi.string().uuid().required(),
    room_condition: Joi.string(),
    key_returned: Joi.boolean(),
    damage_charges: Joi.number().min(0),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateReservation,
  validateCheckIn,
  validateCheckOut,
};
