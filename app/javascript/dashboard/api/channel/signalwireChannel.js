import ApiClient from '../ApiClient';

class SignalwireChannel extends ApiClient {
  constructor() {
    super('channels/signalwire_channel', { accountScoped: true });
  }
}

export default new SignalwireChannel();
