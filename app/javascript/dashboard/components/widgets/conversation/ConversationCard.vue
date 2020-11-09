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
      <button class="conversation--call">
      	<!--<span class="ion-android-call"></span>-->
      	
      	<b-icon icon="telephone-inbound-fill" v-if="isInbounding" animation="throb" font-scale="0.8" @click="incomingCall"></b-icon>
      	<b-icon icon="telephone-fill" v-else @click="outgoingCall"></b-icon>
      </button>
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

import { BIcon, BootstrapVue, BIconTelephoneFill, BIconTelephoneInboundFill } from 'bootstrap-vue';
import 'bootstrap-vue/dist/bootstrap-vue-icons.min.css';

export default {
  components: {
    Thumbnail,
    BIcon,
    BootstrapVue,
    BIconTelephoneFill,
    BIconTelephoneInboundFill,
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
    hideInboxName: {
      type: Boolean,
      default: false,
    },
    hideThumbnail: {
      type: Boolean,
      default: false,
    },
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
    
    isInbounding() {
    	let lastMessage = this.lastMessageInChat;
    	let { content_type: contentType } = lastMessage;
    	if (contentType === 'text' && lastMessage.message_type === 2) {
    		let chat = this.chat;
    		let messages = chat.messages.filter(message => { return message.content_type === 'voice_chat'; });
    		if (messages.length > 0) {
    			lastMessage = messages.last();
    			contentType = lastMessage.content_type;
    		}
    		// contentType = lastMessage.content_type;
    	}
    	return contentType === 'voice_chat';
    },
    
  },
  
  mounted() {
  	this.toggleStatus();
  },

  methods: {
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
    toggleStatus() {
    	// console.log(this.chat);
    	if (this.chat.messages.length < 1) return;
	  	if (this.lastMessageInChat.content_type == 'voice_chat' && this.chat.status === 'bot') {
	  		this.$store.dispatch('toggleStatus', this.chat.id).then(() => {
	        bus.$emit('newToastMessage', this.$t('CONVERSATION.CHANGE_STATUS'));
	      });
	    }
    },
  },
};
</script>
