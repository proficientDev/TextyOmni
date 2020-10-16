import codes from '../codes';
import ApiClient from '../ApiClient';

describe('CodesAPI', () => {
  it('creates correct instance', () => {
    expect(codes).toBeInstanceOf(ApiClient);
    expect(codes).toHaveProperty('get');
    expect(codes).toHaveProperty('show');
    expect(codes).toHaveProperty('create');
    expect(codes).toHaveProperty('update');
    expect(codes).toHaveProperty('delete');
    expect(codes.url).toBe('/api/v1/codes');
  });
});
