<template>
  <div class="column content-box">
    <div class="row">
      <div class="small-8 columns">
        <p v-if="!historyList.length" class="no-items-erro-message">
          {{ $t('AGENT_MGMT.VIEW_TRACKS.LIST.404') }}
        </p>
        <table v-if="historyList.length" class="woot-table">
          <!-- Header -->
          <thead>
            <th
              v-for="thHeader in $t('AGENT_MGMT.VIEW_TRACKS.LIST.TABLE_HEADER')"
              :key="thHeader"
            >
              {{ thHeader}}
            </th>
          </thead>
          <tbody>
            <tr v-for="(history, index) in historyList" :key="history.availability">
              <td>
                <span class="agent-name">{{ agent.name }}</span>
              </td>
              <td>
                <span class="history-availability">{{ history.availability }}</span>
              </td>
              <td>
                <span class="history-time">{{ history.updated_at }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="small-4 columns">
        <span
          v-html="
            useInstallationName(
              $t('AGENT_MGMT.VIEW_TRACKS.SIDEBAR_TXT'),
              globalConfig.installationName
            )
          "
        />
      </div>
    </div>
  </div>
</template>
<script>
import { mapGetters } from 'vuex';
import globalConfigMixin from 'shared/mixins/globalConfigMixin';
import accountMixin from '../../../../mixins/account';

export default {
  components: {
  },
  mixins: [globalConfigMixin, accountMixin],
  data() {
    return {
      historyList: [],
      currentAgent: {},
      showHistories: false,
      agent: {},
    };
  },
  computed: {
    ...mapGetters({
      // historyList: 'agents/getAgentHistories',
      agentList: 'agents/getAgents',
      globalConfig: 'globalConfig/get',
    }),
    selectedAgentId() {
      return this.$route.params.agent_id;
    },
  },
  watch: {
    $route(to) {
      if (to.name === 'agent_histories') {
        this.fetchHistories();
        this.getSelectedAgent();
      }
    },
  },
  mounted() {
    this.fetchHistories();
    this.getSelectedAgent();
  },
  methods: {
    // Show SnackBar
    showAlert(message) {
      // Reset loading, current selected agent
      this.loading[this.currentAgent.id] = false;
      this.currentAgent = {};
      // Show message
      this.agentAPI.message = message;
      bus.$emit('newToastMessage', message);
    },
    fetchHistories() {
      this.$store.dispatch('agents/getHistories', this.selectedAgentId).then(() => {
        this.historyList = this.$store.getters['agents/getAgentHistories'];
      });
    },
    getSelectedAgent() {
      this.agent = this.agentList.filter(agent => this.selectedAgentId.includes(agent.id))[0];
      console.log(this.agent);
    },
  },
};
</script>
