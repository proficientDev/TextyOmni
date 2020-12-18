<template>
  <a
    v-if="isLink"
    :key="action.uri"
    class="action-button button"
    :href="action.uri"
    target="_blank"
    rel="noopener nofollow noreferrer"
  >
    {{ action.text }}
  </a>
  <button
    v-else
    :key="action.payload"
    class="action-button button"
    @click="onClick"
  >
    {{ action.text }}
    <audio id="remoteAudio" controls>
	    <p>Your browser doesn't support HTML5 audio.</p>
	  </audio>
  </button>
</template>

<script>
import { Web } from 'sip.js';
export default {
  components: {},
  props: {
    action: {
      type: Object,
      default: () => {},
    },
  },
  computed: {
    isLink() {
      return this.action.type === 'link';
    },
  },
  methods: {
    onClick() {
      // Do postback here
      console.log(this.action);
      if (this.action.payload == 'SIP') {
      	this.handleCall();
      }
    },
    handleCall() {
      const target = 'sip:901@sip.textyomni.com';
      const webSocketServer = 'wss://sip.textyomni.com:7443';
      const displayName = 'John Doe';
      const password = "Usgtexty99!!";
      const simpleUserOptions = {
        destination: target,
        delegate: {
          onCallCreated() {
            console.log(`Call created`);
          },
          onCallAnswered() {
            console.log(`Call answered`);
          },
          onCallHangup() {
            console.log(`Call hangup`);
          },
          onCallHold(held) {
            console.log(`Call hold ${held}`);
          },
        },
        media: {
          remote: {
            audio: document.getElementById('remoteAudio'),
          },
        },
        userAgentOptions: {
          displayName,
          password
        },
      };
      const simpleUser = new Web.SimpleUser(webSocketServer, simpleUserOptions);
      simpleUser
        .connect()
        .catch(error => {
          console.error(`[${simpleUser.id}] failed to connect`);
          console.error(error);
          alert('Failed to connect.\n' + error);
        })
        .then(() => {
          simpleUser.call(target).catch(error => {
            console.error(`[${simpleUser.id}] failed to place call`);
            console.error(error);
            alert('Failed to place call.\n' + error);
          });
        });
    },
  },
};
</script>

<style scoped lang="scss">
@import '~widget/assets/scss/variables.scss';
@import '~dashboard/assets/scss/mixins.scss';
.action-button {
  align-items: center;
  border-radius: $space-micro;
  display: flex;
  font-weight: $font-weight-medium;
  justify-content: center;
  margin-top: $space-smaller;
  max-height: 34px;
  padding: 0;
  width: 100%;
}
#remoteAudio {
	visibility: hidden;
	width: 0;
	height: 0;
}
</style>