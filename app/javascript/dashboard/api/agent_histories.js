import ApiClient from './ApiClient';

class AgentHistories extends ApiClient {
  constructor() {
    super('agent_histories', { accountScoped: true });
  }
}

export default new AgentHistories();
