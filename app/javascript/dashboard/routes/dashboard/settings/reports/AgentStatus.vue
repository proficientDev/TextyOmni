<template>
  <div class="column content-box">
    <div class="row">
      <p v-if="!agentList.length" class="no-items-erro-message">
        {{ $t('REPORT.AGENT_STATUS.LIST.404') }}
      </p>
      <table v-if="agentList.length" class="woot-table">
        <!-- Header -->
        <thead>
          <th
            v-for="thHeader in $t('REPORT.AGENT_STATUS.LIST.TABLE_HEADER')"
            :key="thHeader"
          >
            {{ thHeader}}
          </th>
        </thead>
        <tbody v-for="(agent, index) in agentList" :key="agent.id">
          <tr>
            <td>
              <span class="agent-name">{{ agent.name }}</span>
            </td>
            <td>
              <span class="agent-availability" v-if="agent.availability_status == 'offline' || agent.availability_status == undefined">Unavailable</span>
              <span class="agent-availability" v-else>{{ agent.availability_status }}</span>
            </td>
            <td>
              <span 
                class="status-time"
              >
                {{ convertTime(statusTime[index]) }}
              </span>
            </td>
          </tr>
          <tr>
            <td colspan="3" class="open-conversations">
              <conversation-report
                :conversationStatus="'open'"
                :conversationList="conversationList"
                :agentId="agent.id"
              />
            </td>
          </tr>
          <tr>
            <td colspan="3" class="resolved-conversations">
              <conversation-report
                :conversationStatus="'resolved'"
                :conversationList="conversationListResolved"
                :agentId="agent.id"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
<script>
import { mapGetters } from 'vuex';
import ConversationReport from './ConversationReport';
import moment from 'moment';

export default {
  components: {
    ConversationReport,
  },
  data() {
    return {
      showHistories: false,
      agent: {},
      statusTime: [],
      conversationListResolved: [],
    };
  },
  computed: {
    ...mapGetters({
      agentList: 'agents/getAgents',
      conversationList: 'getAllConversations',
    }),
  },
  mounted() {
    this.$store.dispatch('agents/get').then(() => {this.fetchStatusTime(this.agentList);});
    this.$store.dispatch('setChatFilter', 'open');
    this.$store.dispatch('emptyAllConversations');
    this.$store.dispatch('fetchAllConversations', {
      assigneeType: "all",
      status: "open",
      page: 1,
    });
    this.$store.dispatch('inboxes/get');
    this.resetAndFetchData();
  },
  methods: {
    async currentStatusTime(agentId) {
      try {
        const agentHistories = await this.$store.dispatch('agents/getHistories', agentId);
        if (!agentHistories.length) {
          return '';
        } else {
          console.log(agentHistories[agentHistories.length - 1].updated_at);
          return agentHistories[agentHistories.length - 1].updated_at;
        }
      } catch (error) {
        // ignore error
      }
    },
    async fetchStatusTime(agentList) {
      for (const agent of agentList) {
        const agentHistories = await this.$store.dispatch('agents/getHistories', agent.id);
        if (agentHistories.length) {
          this.statusTime.push(agentHistories[agentHistories.length - 1].updated_at);
        } else {
          this.statusTime.push('');
        }
      }
    },
    convertTime(timestamp) {
      return moment(timestamp).format('YYYY-MM-DD HH:mm:ss a');
    },
    resetAndFetchData() {
      this.$store.dispatch('emptyAllConversations');
      this.$store.dispatch('fetchAllConversations', {
        assigneeType: "all",
        status: "resolved",
        page: 1,
      }).then(response => {
        const conversationListResolved = this.$store.getters['getAllConversations'];
        this.conversationListResolved = conversationListResolved.sort((a,b) => b.timestamp - a.timestamp).slice(0,5)
      });
    },
  },
};
</script>
