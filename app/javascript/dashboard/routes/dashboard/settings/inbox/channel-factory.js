import Facebook from './channels/Facebook';
import Website from './channels/Website';
import Twitter from './channels/Twitter';
import Twilio from './channels/Twilio';
import Signalwire from './channels/Signalwire';
import Api from './channels/Api';
import Email from './channels/Email';

const channelViewList = {
  facebook: Facebook,
  website: Website,
  twitter: Twitter,
  twilio: Twilio,
  signalwire: Signalwire,
  api: Api,
  email: Email,
};

export default {
  create() {
    return {
      props: {
        channel_name: {
          type: String,
          required: true,
        },
      },
      name: 'new-channel-view',
      render(h) {
        return h(channelViewList[this.channel_name] || null);
      },
    };
  },
};
