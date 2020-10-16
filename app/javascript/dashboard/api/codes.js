import ApiClient from './ApiClient';

class CodesAPI extends ApiClient {
  constructor() {
    super('codes', { accountScoped: true });
  }
}

export default new CodesAPI();
