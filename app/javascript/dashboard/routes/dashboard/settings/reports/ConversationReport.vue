<template>
  <div class="column content-box">
    <p class="sub-title">{{ conversationStatus == 'open' ? $t('REPORT.AGENT_STATUS.ASSIGNED_CONVERSATIONS.OPEN.TITLE') : $t('REPORT.AGENT_STATUS.ASSIGNED_CONVERSATIONS.RESOLVED.TITLE') }}</p>
    <p v-if="!conversationList.length" class="no-items-erro-message">
      {{ $t('REPORT.AGENT_STATUS.LIST.404') }}
    </p>
    <table v-if="conversationList.length" class="woot-table conversation-table">
      <!-- Header -->
      <thead>
        <th
          v-for="thHeader in $t('REPORT.AGENT_STATUS.ASSIGNED_CONVERSATIONS.TABLE_HEADER')"
          :key="thHeader"
        >
          {{ thHeader}}
        </th>
      </thead>
      <tbody><tr><td colspan=4 v-if="showNone" class="no-items-erro-message">
        {{ $t('REPORT.AGENT_STATUS.LIST.404') }}
      </td></tr></tbody>
      <tbody 
        v-for="(conversation, index) in conversationList" :key="conversation.id" 
      >
        <tr 
          v-if="conversation.status == conversationStatus && conversation.meta.assignee && conversation.meta.assignee.id == agentId"
          :list-value="removeNone()"
        >
          <td>
            <span class="conversation-contact">{{ conversation.meta.sender.name }}</span>
          </td>
          <td>
            <span class="conversation-inbox">{{ getInboxName(conversation.inbox_id) }}</span>
          </td>
          <td>
            <span class="conversation-started">{{ conversation.additional_attributes.initiated_at && convertTime(conversation.additional_attributes.initiated_at.timestamp) }}</span>
          </td>
          <td>
            <span 
              class="conversation-duration"
            >
              {{ calculateDuration(conversation) }}
            </span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
import { mapGetters } from 'vuex';
import moment from 'moment';

export default {
  props: {
    conversationStatus: {
      type: String,
      default: '',
    },
    agentId: {
      type: Number,
      default: 0,
    },
    conversationList: {
      type: Array,
      default: [],
    },
  },
  data() {
    return {
      showNone: true,
    };
  },
  computed: {
    ...mapGetters({
      inboxes: 'inboxes/getInboxes',
    }),
  },
  watch: {
    conversationList: {
      handler(conversationList) {
        console.log(conversationList);
      },
      deep: true,
    },
    inboxes: {
      handler(inboxes) {
        // console.log(inboxes);
      },
      deep: true,
    },
  },
  mounted() {
    // this.$store.dispatch('agents/get').then(() => {this.fetchStatusTime(this.conversationList);});
  },
  methods: {
    convertTime(timestamp) {
      return moment(timestamp).format('YYYY-MM-DD HH:mm:ss a');
    },
    calculateDuration(conversation) {
      let tStart = moment(moment(conversation.additional_attributes.initiated_at && conversation.additional_attributes.initiated_at.timestamp).format("YYYY-MM-DD HH:mm"), "YYYY-MM-DD HH:mm");
      let tEnd = moment(moment(conversation.timestamp * 1000).format("YYYY-MM-DD HH:mm"), "YYYY-MM-DD HH:mm");
      let duration = moment.duration(tEnd.diff(tStart));
      let hours = parseInt(duration.asHours());
      let minutes = parseInt(duration.asMinutes())-hours*60;
      if (hours >= 0) {
        return hours + ' : '+ minutes;
      }
    },
    removeNone() {
      this.showNone = false;
    },
    getInboxName(inboxId) {
      return this.inboxes.find(inbox => inbox.id == inboxId).name;
    },
  },
};
</script>
