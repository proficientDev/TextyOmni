import * as MutationHelpers from 'shared/helpers/vuex/mutationHelpers';
import types from '../mutation-types';
import CodesAPI from '../../api/codes';

export const state = {
  records: [],
  uiFlags: {
    isFetching: false,
    isFetchingItem: false,
    isCreating: false,
    isDeleting: false,
  },
};

export const getters = {
  getCodes(_state) {
    return _state.records;
  },
  getUIFlags(_state) {
    return _state.uiFlags;
  }
};

export const actions = {
  get: async function getCodes({ commit }) {
    commit(types.SET_CODE_UI_FLAG, { isFetching: true });
    try {
      const response = await CodesAPI.get();
      commit(types.SET_CODES, response.data.payload);
    } catch (error) {
      // Ignore error
    } finally {
      commit(types.SET_CODE_UI_FLAG, { isFetching: false });
    }
  },

  create: async function createCodes({ commit }, cannedObj) {
    commit(types.SET_CODE_UI_FLAG, { isCreating: true });
    try {
      const response = await CodesAPI.create(cannedObj);
      commit(types.ADD_CODE, response.data);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CODE_UI_FLAG, { isCreating: false });
    }
  },

  update: async function updateCodes({ commit }, { id, ...updateObj }) {
    commit(types.SET_CODE_UI_FLAG, { isUpdating: true });
    try {
      const response = await CodesAPI.update(id, updateObj);
      commit(types.EDIT_CODE, response.data);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CODE_UI_FLAG, { isUpdating: false });
    }
  },

  delete: async function deleteCodes({ commit }, id) {
    commit(types.SET_CODE_UI_FLAG, { isDeleting: true });
    try {
      await CodesAPI.delete(id);
      commit(types.DELETE_CODE, id);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CODE_UI_FLAG, { isDeleting: false });
    }
  },
};

export const mutations = {
  [types.SET_CODE_UI_FLAG](_state, data) {
    _state.uiFlags = {
      ..._state.uiFlags,
      ...data,
    };
  },

  [types.SET_CODES]: MutationHelpers.set,
  [types.ADD_CODE]: MutationHelpers.create,
  [types.EDIT_CODE]: MutationHelpers.update,
  [types.DELETE_CODE]: MutationHelpers.destroy,
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
