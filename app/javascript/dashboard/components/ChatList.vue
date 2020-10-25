<template>
  <div class="conversations-sidebar  medium-4 columns">
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
        :key="chat.id"
        :active-label="label"
        :chat="chat"
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
/* global bus */
import { mapGetters } from 'vuex';

import ChatFilter from './widgets/conversation/ChatFilter';
import ChatTypeTabs from './widgets/ChatTypeTabs';
import ConversationCard from './widgets/conversation/ConversationCard';
import timeMixin from '../mixins/time';
import conversationMixin from '../mixins/conversations';
import wootConstants from '../constants';

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
      
      // Return filtered array with searched contacts
      if (this.contactsSearched) {
        const conversations = conversationList.filter(conversation => 
          this.contactsSearched.some(contact => contact.id == conversation.meta.sender.id));
        return conversations;
      }

      if (!this.label) {
        return conversationList;
      }

      return conversationList.filter(conversation => {
        const labels = this.$store.getters[
          'conversationLabels/getConversationLabels'
        ](conversation.id);
        return labels.includes(this.label);
      });
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
  },
  methods: {
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
</style>
