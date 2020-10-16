import { required, minLength } from 'vuelidate/lib/validators';

export const validCodeCharacters = (str = '') => !!str;

export default {
  title: {
    required,
    minLength: minLength(2),
    validCodeCharacters,
  },
  description: {}
};
