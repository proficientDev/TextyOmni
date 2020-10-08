import { getters } from '../../codes';
import codes from './fixtures';
describe('#getters', () => {
  it('getCodes', () => {
    const state = { records: codes };
    expect(getters.getCodes(state)).toEqual(codes);
  });

  it('getCodesOnSidebar', () => {
    const state = { records: code };
    expect(getters.getCodesOnSidebar(state)).toEqual([codes[0]]);
  });

  it('getUIFlags', () => {
    const state = {
      uiFlags: {
        isFetching: true,
        isCreating: false,
        isUpdating: false,
        isDeleting: false,
      },
    };
    expect(getters.getUIFlags(state)).toEqual({
      isFetching: true,
      isCreating: false,
      isUpdating: false,
      isDeleting: false,
    });
  });
});
