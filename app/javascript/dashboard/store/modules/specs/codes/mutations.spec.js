import types from '../../../mutation-types';
import { mutations } from '../../codes';
import codes from './fixtures';
describe('#mutations', () => {
  describe('#SET_CODES', () => {
    it('set code records', () => {
      const state = { records: [] };
      mutations[types.SET_CODES](state, codes);
      expect(state.records).toEqual(codes);
    });
  });

  describe('#ADD_CODE', () => {
    it('push newly created code to the store', () => {
      const state = { records: [codes[0]] };
      mutations[types.ADD_CODE](state, codes[1]);
      expect(state.records).toEqual([codes[0], codes[1]]);
    });
  });

  describe('#EDIT_CODE', () => {
    it('update code record', () => {
      const state = { records: [codes[0]] };
      mutations[types.EDIT_CODE](state, {
        id: 1,
        title: 'customer-support-queries',
      });
      expect(state.records[0].title).toEqual('customer-support-queries');
    });
  });

  describe('#DELETE_CODE', () => {
    it('delete code record', () => {
      const state = { records: [codes[0]] };
      mutations[types.DELETE_CODE](state, 1);
      expect(state.records).toEqual([]);
    });
  });
});
