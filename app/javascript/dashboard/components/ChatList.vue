<template>
  <div class="conversations-sidebar  medium-4 columns">
    <div class="chat-list__top">
      <h1 class="page-title">
        <woot-sidemenu-icon />
        {{ pageTitle }}
      </h1>

      <chat-filter @statusFilterChange="updateStatusType" />
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
        :call-btn.sync="chat.callBtn"
        :handle-call="handleCall"
        :handle-hang-up="handleHangUp"
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
/* eslint-env browser */
/* eslint no-console: 0 */

import { mapGetters } from 'vuex';

import ChatFilter from './widgets/conversation/ChatFilter';
import ChatTypeTabs from './widgets/ChatTypeTabs';
import ConversationCard from './widgets/conversation/ConversationCard';
import timeMixin from '../mixins/time';
import conversationMixin from '../mixins/conversations';
import wootConstants from '../constants';
import { Web } from 'sip.js';

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
      simpleUser: null,
      calls: {},
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
    }),
    assigneeTabItems() {
      return this.$t('CHAT_LIST.ASSIGNEE_TYPE_TABS').map(item => {
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
    const target = 'sip:andryifabr@vevidi.onsip.com';
    const webSocketServer = 'wss://edge.sip.onsip.com';
    const displayName = 'Andriy';

    const simpleUserOptions = {
      aor: target,
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
      },
    };

    this.simpleUser = new Web.SimpleUser(webSocketServer, simpleUserOptions);

    this.simpleUser
      .connect()
      .catch(error => {
        console.error(`[${this.simpleUser.id}] failed to connect`);
        console.error(error);
        alert('Failed to connect.\n' + error);
      })
      .then(() => {
        this.simpleUser.register().then(() => {
          this.simpleUser.delegate = {
            onCallReceived() {
              const callId = self.simpleUser.session.id;
              self.allChatList.forEach(c => {
                c.messages.forEach(m => {
                  if (callId.indexOf(m.content) !== -1) {
                    self.calls[c.id] = true;
                  }
                });
              });
            },
            onCallHangup() {
              self.allChatList.forEach(c => {
                self.calls[c.id] = false;
              });
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
      this.calls = { ...this.calls, id: false };
      this.$nextTick(() => {
        this.$forceUpdate();
      });
      this.simpleUser.hangup();
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
