<template>
  <div
    class="conversation"
    :class="{ active: isActiveChat, 'unread-chat': hasUnread }"
    @click="cardClick(chat)"
  >
    <Thumbnail
      v-if="!hideThumbnail"
      :src="currentContact.thumbnail"
      :badge="chatMetadata.channel"
      class="columns"
      :username="currentContact.name"
      :status="currentContact.availability_status"
      size="40px"
    />
    <div class="conversation--details columns">
      <h4 class="conversation--user">
        {{ currentContact.name }}
        <span
          v-if="!hideInboxName && isInboxNameVisible"
          v-tooltip.bottom="inboxName(chat.inbox_id)"
          class="label"
        >
          {{ inboxName(chat.inbox_id) }}
        </span>
      </h4>
      <p v-if="lastMessageInChat" class="conversation--message">
        <i v-if="messageByAgent" class="ion-ios-undo message-from-agent"></i>
        <span v-if="lastMessageInChat.content">
          {{ lastMessageInChat.content }}
        </span>
        <span v-else-if="!lastMessageInChat.attachments">{{ ` ` }}</span>
        <span v-else>
          <i :class="`small-icon ${this.$t(`${attachmentIconKey}.ICON`)}`"></i>
          {{ this.$t(`${attachmentIconKey}.CONTENT`) }}
        </span>
      </p>
      <div class="conversation--meta">
        <span class="timestamp">
          {{ dynamicTime(chat.timestamp) }}
        </span>
        <span class="unread">{{ getUnreadCount }}</span>
      </div>
      <div v-if="callBtn">
        <button v-if="call" class="accept-call" @click="acceptCall"></button>
        <button class="decline-call" @click="declineCall"></button>
      </div>
    </div>
  </div>
</template>
<script>
import { mapGetters } from 'vuex';
import { MESSAGE_TYPE } from 'widget/helpers/constants';

import Thumbnail from '../Thumbnail';
import conversationMixin from '../../../mixins/conversations';
import timeMixin from '../../../mixins/time';
import router from '../../../routes';
import { frontendURL, conversationUrl } from '../../../helper/URLHelper';

export default {
  components: {
    Thumbnail,
  },
  mixins: [timeMixin, conversationMixin],
  props: {
    activeLabel: {
      type: String,
      default: '',
    },
    chat: {
      type: Object,
      default: () => {},
    },
    callBtn: {
      type: Boolean,
      default: false,
    },
    hideInboxName: {
      type: Boolean,
      default: false,
    },
    hideThumbnail: {
      type: Boolean,
      default: false,
    },
    handleCall: {
      type: Function,
      default: () => {},
    },
    handleHangUp: {
      type: Function,
      default: () => {},
    },
  },
  data() {
    return {
      call: true,
      callBtnToggle: false,
    };
  },

  computed: {
    ...mapGetters({
      currentChat: 'getSelectedChat',
      inboxesList: 'inboxes/getInboxes',
      activeInbox: 'getSelectedInbox',
      currentUser: 'getCurrentUser',
      accountId: 'getCurrentAccountId',
    }),

    chatMetadata() {
      return this.chat.meta;
    },

    currentContact() {
      return this.$store.getters['contacts/getContact'](
        this.chatMetadata.sender.id
      );
    },

    attachmentIconKey() {
      const lastMessage = this.lastMessageInChat;
      const [{ file_type: fileType } = {}] = lastMessage.attachments;
      return `CHAT_LIST.ATTACHMENTS.${fileType}`;
    },

    isActiveChat() {
      return this.currentChat.id === this.chat.id;
    },

    getUnreadCount() {
      return this.unreadMessagesCount(this.chat);
    },

    hasUnread() {
      return this.getUnreadCount > 0;
    },

    isInboxNameVisible() {
      return !this.activeInbox;
    },

    lastMessageInChat() {
      return this.lastMessage(this.chat);
    },

    messageByAgent() {
      const lastMessage = this.lastMessageInChat;
      const { message_type: messageType } = lastMessage;
      return messageType === MESSAGE_TYPE.OUTGOING;
    },
  },
  watch: {
    $props: {
      intermediate: true,
      deep: true,
      handler(newVal) {
        this.$nextTick(() => {
          this.callBtnToggle = newVal.callBtn;
        });
      },
    },
  },
  methods: {
    acceptCall() {
      this.handleCall(this.chat.id);
      this.call = false;
    },
    declineCall() {
      this.handleHangUp(this.chat.id);
      this.callBtnToggle = false;
    },
    cardClick(chat) {
      const { activeInbox } = this;
      const path = conversationUrl({
        accountId: this.accountId,
        activeInbox,
        id: chat.id,
        label: this.activeLabel,
      });
      router.push({ path: frontendURL(path) });
    },
    inboxName(inboxId) {
      const stateInbox = this.$store.getters['inboxes/getInbox'](inboxId);
      return stateInbox.name || '';
    },
  },
};
</script>

<style>
.accept-call {
  background: url('../../../../../javascript/shared/assets/images/accept-call.png');
  width: 32px;
  height: 32px;
  border: 1px solid green;
  border-radius: 16px;
}
.decline-call {
  background: url('../../../../../javascript/shared/assets/images/decline-call.png');
  width: 32px;
  height: 32px;
  border: 1px solid red;
  border-radius: 16px;
}
</style>
