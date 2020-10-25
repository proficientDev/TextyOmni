/* global axios */
import ApiClient from './ApiClient';

class ContactSearchAPI extends ApiClient {
  constructor() {
    super('contacts', { accountScoped: true });
  }

  getContacts(keyWords) {
    return axios.get(`${this.url}/search?q=${keyWords}`);
  }
}

export default new ContactSearchAPI();
