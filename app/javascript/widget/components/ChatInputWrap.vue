<template>
  <div class="chat-message--input">
    <resizable-text-area
      v-model="userInput"
      :placeholder="$t('CHAT_PLACEHOLDER')"
      class="form-input user-message-input"
      @focus="onFocus"
      @blur="onBlur"
    />
    <div class="button-wrap">
      <audio id="remoteAudio" controls>
        <p>Your browser doesn't support HTML5 audio.</p>
      </audio>
      <button
        class="call-btn"
        :class="{
          'accept-call': callBtn === 'call',
          'decline-call': callBtn === 'hangup',
        }"
        @click="handleCallButton()"
      ></button>
      <chat-attachment-button
        v-if="showAttachment"
        :on-attach="onSendAttachment"
      />
      <emoji-input
        v-if="showEmojiPicker"
        v-on-clickaway="hideEmojiPicker"
        :on-click="emojiOnClick"
      />
      <i
        v-if="hasEmojiPickerEnabled"
        class="emoji-toggle icon ion-happy-outline"
        :class="{ active: showEmojiPicker }"
        @click="toggleEmojiPicker()"
      />
      <chat-send-button
        v-if="showSendButton"
        :on-click="handleButtonClick"
        :color="widgetColor"
      />
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import emojione from 'emojione';
import { mixin as clickaway } from 'vue-clickaway';
import ChatSendButton from 'widget/components/ChatSendButton.vue';
import ChatAttachmentButton from 'widget/components/ChatAttachment.vue';
import ResizableTextArea from 'shared/components/ResizableTextArea';
import EmojiInput from 'dashboard/components/widgets/emoji/EmojiInput';
import configMixin from '../mixins/configMixin';
import { Web } from 'sip.js';

export default {
  name: 'ChatInputWrap',
  components: {
    ChatAttachmentButton,
    ChatSendButton,
    EmojiInput,
    ResizableTextArea,
  },
  mixins: [clickaway, configMixin],
  props: {
    onSendMessage: {
      type: Function,
      default: () => {},
    },
    onSendAttachment: {
      type: Function,
      default: () => {},
    },
  },

  data() {
    return {
      userInput: '',
      showEmojiPicker: false,
      callBtn: 'call',
      simpleUserObject: null,
    };
  },

  computed: {
    ...mapGetters({
      widgetColor: 'appConfig/getWidgetColor',
    }),
    showAttachment() {
      return this.hasAttachmentsEnabled && this.userInput.length === 0;
    },
    showSendButton() {
      return this.userInput.length > 0;
    },
  },

  destroyed() {
    document.removeEventListener('keypress', this.handleEnterKeyPress);
  },
  mounted() {
    document.addEventListener('keypress', this.handleEnterKeyPress);
  },

  methods: {
    handleCallButton() {
      if (this.callBtn === 'call') {
        this.handleCall();
      }
      if (this.callBtn === 'hangup') {
        this.handleHangup();
      }
    },
    handleCall() {
      const self = this;
      const target = 'sip:andryifabr@vevidi.onsip.com';
      const webSocketServer = 'wss://edge.sip.onsip.com';
      const displayName = 'Andriy';

      const simpleUserOptions = {
        destination: target,
        media: {
          remote: {
            audio: document.getElementById('remoteAudio'),
          },
        },
        userAgentOptions: {
          displayName,
        },
      };

      const simpleUser = new Web.SimpleUser(webSocketServer, simpleUserOptions);

      this.simpleUserObject = simpleUser;

      const delegate = {
        onCallCreated() {
          console.log(`Call created`);
          const content = simpleUser.session.id.substr(
            0,
            simpleUser.session.id.indexOf(simpleUser.session.fromTag)
          );
          const contentType = 9;
          self.onSendMessage({ content, contentType });
        },
        onCallAnswered() {
          console.log(`Call answered`);
        },
        onCallHangup() {
          console.log(`Call hangup`);
          self.callBtn = 'call';
        },
        onCallHold(held) {
          console.log(`Call hold ${held}`);
        },
      };

      simpleUser.delegate = delegate;

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
          this.callBtn = 'hangup';
        });
    },
    handleHangup() {
      this.simpleUserObject.hangup();
      this.callBtn = 'call';
    },
    handleButtonClick() {
      if (this.userInput && this.userInput.trim()) {
        this.onSendMessage({ content: this.userInput });
      }
      this.userInput = '';
    },
    handleEnterKeyPress(e) {
      if (e.keyCode === 13 && !e.shiftKey) {
        e.preventDefault();
        this.handleButtonClick();
      }
    },
    toggleEmojiPicker() {
      this.showEmojiPicker = !this.showEmojiPicker;
    },
    hideEmojiPicker() {
      if (this.showEmojiPicker) {
        this.toggleEmojiPicker();
      }
    },
    emojiOnClick(emoji) {
      this.userInput = emojione.shortnameToUnicode(
        `${this.userInput}${emoji.shortname} `
      );
    },

    onBlur() {
      this.toggleTyping('off');
    },
    onFocus() {
      this.toggleTyping('on');
    },
    toggleTyping(typingStatus) {
      this.$store.dispatch('conversation/toggleUserTyping', { typingStatus });
    },
  },
};
</script>

<style scoped lang="scss">
@import '~widget/assets/scss/variables.scss';

#remoteAudio {
  visibility: hidden;
  width: 0;
  height: 0;
}
.chat-message--input {
  align-items: center;
  display: flex;
}

.emoji-toggle {
  font-size: $font-size-large;
  color: $color-gray;
  padding-right: $space-smaller;
  cursor: pointer;
}

.emoji-dialog {
  right: $space-one;
}

.file-uploads {
  margin-right: $space-small;
}

.button-wrap {
  display: flex;
  align-items: center;
}

.user-message-input {
  border: 0;
  height: $space-large;
  min-height: $space-large;
  max-height: 2.4 * $space-mega;
  resize: none;
  padding-top: $space-small;
}

.accept-call {
  background: url('../../../javascript/shared/assets/images/accept-call.png');
  background-size: contain;
  width: 20px;
  height: 20px;
  border: 1px solid green;
  border-radius: 10px;
}
.decline-call {
  background: url('../../../javascript/shared/assets/images/decline-call.png');
  background-size: contain;
  width: 20px;
  height: 20px;
  border: 1px solid red;
  border-radius: 10px;
}
.call-btn {
  margin-right: 10px;
  cursor: pointer;
}
.call-btn:focus {
  outline: none;
}
</style>
