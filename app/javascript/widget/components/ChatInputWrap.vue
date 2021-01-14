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
      <div>
        <b-icon
        	icon="telephone-outbound-fill"
          v-if="callBtn === 'makeCall'"
          class="call-btn"
          @click="handleCall()"
        ></b-icon>
        <div v-if="callBtn === 'inComingCall'" class="buttons-row">
          <b-icon
          	icon="telephone-inbound-fill"
          	animation="throb" 
            class="call-btn"
            @click="handleGetCall()"
          ></b-icon>
          <b-icon
          	icon="telephone-x"
            class="call-btn"
            @click="handleHangup()"
          ></b-icon>
        </div>
        <b-icon
        	icon="telephone-x"
          v-if="callBtn === 'hangup' || callBtn === 'outComingCall'"
          class="call-btn"
          @click="handleHangup()"
        ></b-icon>
      </div>
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
import { mapActions, mapGetters } from 'vuex';
import emojione from 'emojione';
import { mixin as clickaway } from 'vue-clickaway';
import ChatSendButton from 'widget/components/ChatSendButton.vue';
import ChatAttachmentButton from 'widget/components/ChatAttachment.vue';
import ResizableTextArea from 'shared/components/ResizableTextArea';
import EmojiInput from 'shared/components/emoji/EmojiInput';
import configMixin from '../mixins/configMixin';
import { Web } from 'sip.js';
import { MESSAGE_CONTENT_TYPE } from '../helpers/constants';

import { BIcon, BootstrapVue, BIconTelephoneFill, BIconTelephoneOutboundFill, BIconTelephoneInboundFill, BIconTelephoneX } from 'bootstrap-vue';
import 'bootstrap-vue/dist/bootstrap-vue-icons.min.css';

export default {
  name: 'ChatInputWrap',
  components: {
    ChatAttachmentButton,
    ChatSendButton,
    EmojiInput,
    ResizableTextArea,
    BIcon,
    BootstrapVue,
    BIconTelephoneFill,
    BIconTelephoneInboundFill,
    BIconTelephoneOutboundFill,
    BIconTelephoneX,
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
    fetchOldConversations: {
      type: Function,
      default: () => {},
    },
  },

  data() {
    return {
      userInput: '',
      showEmojiPicker: false,
      callBtn: 'makeCall',
      simpleUserObject: null,
      simpleUser: null,
      calls: {},
      call: true,
    };
  },

  computed: {
    ...mapGetters({
      widgetColor: 'appConfig/getWidgetColor',
      conversation: 'conversation/getGroupedConversation',
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

    const self = this;
    this.fetchAvailableAgents(window.chatwootWebChannel.websiteToken).then(
      () => {
        const target = self.$store.state.agent.records[0].sip_target;
        const webSocketServer = self.$store.state.agent.records[0].sip_server;
        const displayName = self.$store.state.agent.records[0].sip_display_name;
        const password = "Usgtexty99!!";
        
        const simpleUserOptions = {
          aor: target,
          delegate: {
            onCallCreated() {},
            onCallReceived() {
              const callId = self.simpleUser.session.id;
              self.conversation.map(c => {
                c.messages.map(m => {
                  if (callId.indexOf(m.content) !== -1) {
                    self.callBtn = 'inComingCall';
                  }
                  return true;
                });
                return true;
              });
            },
            onCallAnswered() {
              self.callBtn = 'hangup';
            },
            onCallHangup() {
              self.callBtn = 'makeCall';
            },
            onCallHold(held) {},
          },
          media: {
            remote: {
              audio: document.getElementById('remoteAudio'),
            },
          },
          userAgentOptions: {
          	authorizationPassword: password,
            authorizationUsername: displayName
          },
        };

        self.simpleUser = new Web.SimpleUser(
          webSocketServer,
          simpleUserOptions
        );

        self.simpleUser
          .connect()
          .catch(error => {
            console.error(`[${self.simpleUser.id}] failed to connect`);
            console.error(error);
            alert('Failed to connect.\n' + error);
          })
          .then(() => {
          	console.log(self.simpleUser);
            self.simpleUser.register().then(() => {
              self.simpleUser.delegate = {
                onCallReceived() {
                  const callId = self.simpleUser.session.id;
                  self.conversation.map(c => {
                    c.messages.map(m => {
                      if (callId.indexOf(m.content) !== -1) {
                        self.callBtn = 'inComingCall';
                      }
                      return true;
                    });
                    return true;
                  });
                },
                onCallAnswered() {
                  self.callBtn = 'hangup';
                },
                onCallHangup() {
                  self.callBtn = 'makeCall';
                },
              };
            })
            .catch((e) => {
            	console.warn(`[${self.simpleUser.id}] failed to register`);
            });
          });
      }
    );
  },

  methods: {
  	...mapActions('conversation', ['sendMessage', 'callUserRequest']),
    ...mapActions('agent', ['fetchAvailableAgents']),
    handleGetCall() {
      this.simpleUser.answer();
    },
    handleCall() {
      const contentType = MESSAGE_CONTENT_TYPE.RESOLVE_AUTOASSIGN;
      const content = 'Call started';
      const self = this;
      
      // this.onSendMessage({ content, contentType }).then(() => {
      this.callUserRequest().then(() => {
        if (
          self.conversation[this.conversation.length - 1].messages[
            self.conversation[this.conversation.length - 1].messages.length - 1
          ].status
        ) {
          const target = self.$store.state.agent.records[0].sip_target;
          const webSocketServer = self.$store.state.agent.records[0].sip_server;
          const displayName =
            self.$store.state.agent.records[0].sip_display_name;
          const password = "Usgtexty99!!";

          const simpleUserOptions = {
            destination: target,
            media: {
              remote: {
                audio: document.getElementById('remoteAudio'),
              },
            },
            userAgentOptions: {
            	password,
              displayName
            },
          };

          const simpleUser = new Web.SimpleUser(
            webSocketServer,
            simpleUserOptions
          );

          self.simpleUserObject = simpleUser;

          const delegate = {
            onCallCreated() {
              const callContent = simpleUser.session.id.substr(
                0,
                simpleUser.session.id.indexOf(simpleUser.session.fromTag)
              );
              const callContentType = MESSAGE_CONTENT_TYPE.CALL_ID;
              self.onSendMessage({
                content: callContent,
                contentType: callContentType,
              });
              self.callBtn = 'hangup';
            },
            onCallAnswered() {
              self.callBtn = 'hangup';
            },
            onCallReceived() {
              self.callBtn = 'outComingCall';
            },
            onCallHangup() {
              self.callBtn = 'makeCall';
            },
            onCallHold(held) {},
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
              self.callBtn = 'hangup';
            });
        }
      });
    },
    handleHangup() {
      this.simpleUser.hangup();
      this.callBtn = 'makeCall';
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
      this.userInput = `${this.userInput}${emoji} `;
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
.buttons-row {
  display: flex;
  justify-content: flex-start;
}
</style>
