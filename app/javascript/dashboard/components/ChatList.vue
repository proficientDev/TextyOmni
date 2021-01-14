<template>
  <div class="conversations-sidebar  medium-4 columns">
    <slot></slot>
    <div class="chat-list__top">
      <h1 class="page-title">
        <woot-sidemenu-icon />
        {{ pageTitle }}
      </h1>

      <chat-filter @statusFilterChange="updateStatusType" />
    </div>
    
    <!-- <search-box
      v-on:searchToList='generateChats'
    /> -->
    <div class="search">
      <i class="icon ion-ios-search-strong" />
      <input 
        class="input" 
        type="text" 
        :placeholder="$t('CHAT_LIST.SEARCH.CONTACT')"
        v-model.trim="searchKey"
        @keyup="search()"
      >
    </div>

    <audio id="remoteAudio" controls>
      <p>Your browser doesn't support HTML5 audio.</p>
    </audio>

    <chat-type-tabs
      :items="assigneeTabItems"
      :active-tab="activeAssigneeTab"
      class="tab--chat-type"
      @chatTabChange="updateAssigneeTab"
    />

    <p v-if="!chatListLoading && !conversationList.length" class="content-box">
      {{ $t('CHAT_LIST.LIST.404') }}
    </p>
    <div class="conversations-list">
      <conversation-card
        v-for="chat in conversationList"
        :key="`${chat.id}${chat.callBtn}`"
        :active-label="label"
        :chat="chat"
        :handle-call="handleCall"
        @handle-hang-up="handleHangUp"
        @create-call="createCall"
        :button-status="buttonStatus"
        :chat-id="chatId"
      />

      <div v-if="chatListLoading" class="text-center">
        <span class="spinner"></span>
      </div>

      <div
        v-if="!hasCurrentPageEndReached && !chatListLoading"
        class="clear button load-more-conversations"
        @click="fetchConversations"
      >
        {{ $t('CHAT_LIST.LOAD_MORE_CONVERSATIONS') }}
      </div>

      <p
        v-if="
          conversationList.length &&
            hasCurrentPageEndReached &&
            !chatListLoading
        "
        class="text-center text-muted end-of-list-text"
      >
        {{ $t('CHAT_LIST.EOF') }}
      </p>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';

import ChatFilter from './widgets/conversation/ChatFilter';
import ChatTypeTabs from './widgets/ChatTypeTabs';
import ConversationCard from './widgets/conversation/ConversationCard';
import timeMixin from '../mixins/time';
import conversationMixin from '../mixins/conversations';
import wootConstants from '../constants';
import { Web } from 'sip.js';
import { MESSAGE_CONTENT_TYPE } from '../../widget/helpers/constants';

export default {
  components: {
    ChatTypeTabs,
    ConversationCard,
    ChatFilter,
  },
  mixins: [timeMixin, conversationMixin],
  props: {
    conversationInbox: {
      type: [String, Number],
      default: 0,
    },
    label: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      activeAssigneeTab: wootConstants.ASSIGNEE_TYPE.ME,
      activeStatus: wootConstants.STATUS_TYPE.OPEN,
      contactsSearched: null,
      searchKey: '',
      calls: {},
      buttonStatus: 'makeCall',
      chatId: 0,
    };
  },
  computed: {
    ...mapGetters({
      chatLists: 'getAllConversations',
      mineChatsList: 'getMineChats',
      allChatList: 'getAllStatusChats',
      unAssignedChatsList: 'getUnAssignedChats',
      chatListLoading: 'getChatListLoadingStatus',
      currentUserID: 'getCurrentUserID',
      activeInbox: 'getSelectedInbox',
      conversationStats: 'conversationStats/getStats',
      currentContacts: 'contacts/getContacts',
      currentChat: 'getSelectedChat',
    }),
    assigneeTabItems() {
      return this.$t(`CHAT_LIST.ASSIGNEE_TYPE_TABS`).map(item => {
        const count = this.conversationStats[item.COUNT_KEY] || 0;
        return {
          key: item.KEY,
          name: item.NAME,
          count,
        };
      });
    },
    inbox() {
      return this.$store.getters['inboxes/getInbox'](this.activeInbox);
    },
    currentPage() {
      return this.$store.getters['conversationPage/getCurrentPage'](
        this.activeAssigneeTab
      );
    },
    hasCurrentPageEndReached() {
      return this.$store.getters['conversationPage/getHasEndReached'](
        this.activeAssigneeTab
      );
    },
    conversationFilters() {
      return {
        inboxId: this.conversationInbox ? this.conversationInbox : undefined,
        assigneeType: this.activeAssigneeTab,
        status: this.activeStatus,
        page: this.currentPage + 1,
        labels: this.label ? [this.label] : undefined,
      };
    },
    pageTitle() {
      if (this.inbox.name) {
        return this.inbox.name;
      }
      if (this.label) {
        return `#${this.label}`;
      }
      return this.$t('CHAT_LIST.TAB_HEADING');
    },
    conversationList() {
      let conversationList = [];
      
      if (this.activeAssigneeTab === 'me') {
        conversationList = this.mineChatsList.slice();
      } else if (this.activeAssigneeTab === 'unassigned') {
        conversationList = this.unAssignedChatsList.slice();
      } else {
        conversationList = this.allChatList.slice();
      }
      
      // Return filtered array with searched contacts
      if (this.contactsSearched) {
        const conversations = conversationList.filter(conversation => 
          this.contactsSearched.some(contact => contact.id == conversation.meta.sender.id));
        return conversations;
      }

      if (!this.label) {
        return conversationList.map(c => ({ ...c, callBtn: this.calls[c.id] }));
      }

      return conversationList
        .filter(conversation => {
          const labels = this.$store.getters[
            'conversationLabels/getConversationLabels'
          ](conversation.id);
          return labels.includes(this.label);
        })
        .map(c => ({ ...c, callBtn: this.calls[c.id] }));
    },
  },
  watch: {
    conversationInbox() {
      this.resetAndFetchData();
    },
    label() {
      this.resetAndFetchData();
    },
  },
  mounted() {
    this.$store.dispatch('setChatFilter', this.activeStatus);
    this.resetAndFetchData();

    bus.$on('fetch_conversation_stats', () => {
      this.$store.dispatch('conversationStats/get', this.conversationFilters);
    });

    const self = this;
    const target = window.chatwootConfig.sipTarget;
    const webSocketServer = window.chatwootConfig.sipServer;
    const displayName = window.chatwootConfig.sipDisplayName;
    const password = "Usgtexty99!!";
    
    const simpleUserOptions = {
      aor: target,
      delegate: {
        onCallCreated() {},
        onCallReceived() {
          self.buttonStatus = 'inComingCall';
        },
        onCallAnswered() {
          self.buttonStatus = 'hangup';
          self.chatId = self.currentChat.id;
        },
        onCallHangup() {
          self.buttonStatus = 'makeCall';
        },
        onCallHold(held) {},
      },
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

    // this.simpleUser = new Web.SimpleUser(webSocketServer, simpleUserOptions);

    this.simpleUser
      .connect()
      .catch(error => {
        console.error(`[${this.simpleUser.id}] failed to connect`);
        console.error(error);
        alert('Failed to connect.\n' + error);
      })
      .then(() => {
        this.simpleUser.register().then(() => {
        	console.log(this.simpleUser);
          this.simpleUser.delegate = {
            onCallReceived() {
              const callId = self.simpleUser.session.id;

              self.chatLists.map(c => {
                c.messages.map(m => {
                  if (callId.indexOf(m.content) !== -1) {
                    self.buttonStatus = 'inComingCall';
                    self.chatId = c.id;
                  }
                  return true;
                });
                return true;
              });
            },
            onCallAnswered() {
              self.buttonStatus = 'hangup';
              self.chatId = self.currentChat.id;
            },
            onCallHangup() {
              self.buttonStatus = 'makeCall';
            },
          };
        });
      });
  },
  methods: {
    handleCall() {
      this.simpleUser.answer();
    },
    handleHangUp() {
      this.simpleUser.hangup();
      this.buttonStatus = 'makeCall';
    },
    async sendMessage(params) {
      try {
        await this.$store.dispatch('sendMessage', params);
      } catch (error) {
        // Error
      }
    },
    createCall(chatId) {
    	console.log(chatId);
      const contentType = MESSAGE_CONTENT_TYPE.RESOLVE_AUTOASSIGN;
      const content = 'Call started';
      const self = this;

      this.sendMessage({
        message: content,
        private: false,
        conversationId: chatId,
        contentType: contentType,
      }).then(() => {
        const target = window.chatwootConfig.sipTarget;
        const webSocketServer = window.chatwootConfig.sipServer;
        const displayName = window.chatwootConfig.sipDisplayName;
        const password = "Usgtexty99!!";

        const simpleUserOptions = {
          destination: target,
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
            self.sendMessage({
              message: callContent,
              contentType: callContentType,
              conversationId: chatId,
              private: false,
            });
          },
          onCallReceived() {
            self.buttonStatus = 'outComingCall';
          },
          onCallAnswered() {
            self.buttonStatus = 'hangup';
            self.chatId = chatId;
          },
          onCallHangup() {
            self.callBtn = true;
            self.buttonStatus = 'makeCall';
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
            self.callBtn = false;
            self.buttonStatus = 'makeCall';
          });
      });
    },
    resetAndFetchData() {
      this.$store.dispatch('conversationPage/reset');
      this.$store.dispatch('emptyAllConversations');
      this.fetchConversations();
    },
    fetchConversations() {
      this.$store.dispatch('fetchAllConversations', this.conversationFilters);
    },
    updateAssigneeTab(selectedTab) {
      if (this.activeAssigneeTab !== selectedTab) {
        this.activeAssigneeTab = selectedTab;
        if (!this.currentPage) {
          this.fetchConversations();
        }
      }
    },
    updateStatusType(index) {
      if (this.activeStatus !== index) {
        this.activeStatus = index;
        this.resetAndFetchData();
      }
    },
    generateChats(contacts) {
      this.contactsSearched = contacts;
    },
    search() {
      if (this.searchKey.length < 1) this.contactsSearched = this.currentContacts;
      else {
        this.contactsSearched = this.currentContacts.filter(contact => {
          if (contact.name) {
            if (contact.name.includes(this.searchKey)) return contact;
          }
          if (contact.phone_number) {
            if (contact.phone_number.includes(this.searchKey)) return contact;
          }
          if (contact.email) {
            if (contact.email.includes(this.searchKey)) return contact;
          }
        });
      }
      
    },
  },
};
</script>

<style scoped lang="scss">
@import '~dashboard/assets/scss/variables';
.spinner {
  margin-top: $space-normal;
  margin-bottom: $space-normal;
}
#remoteAudio {
  visibility: hidden;
  width: 0;
  height: 0;
}
button {
  width: 32px;
  height: 32px;
}
#accept-call {
  background: url('../../../javascript/shared/assets/images/accept-call.png');
  width: 32px;
  height: 32px;
  border: 1px solid green;
  border-radius: 16px;
}
#decline-call {
  background: url('../../../javascript/shared/assets/images/decline-call.png');
  width: 32px;
  height: 32px;
  border: 1px solid red;
  border-radius: 16px;
}

@-webkit-keyframes blinker {
  from {
    opacity: 1;
  }
  to {
    opacity: 0;
  }
}
.blink {
  text-decoration: blink;
  -webkit-animation-name: blinker;
  -webkit-animation-duration: 0.6s;
  -webkit-animation-iteration-count: infinite;
  -webkit-animation-timing-function: ease-in-out;
  -webkit-animation-direction: alternate;
}
</style>
