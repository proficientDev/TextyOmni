<template>
  <grouped-avatars :users="users" />
</template>

<script>
import GroupedAvatars from 'widget/components/GroupedAvatars.vue';
// import agentMixin from '../mixins/agentMixin';
import globalConfigMixin from 'shared/mixins/globalConfigMixin';

export default {
  name: 'AvailableAgents',
  components: { GroupedAvatars },
  mixins: [globalConfigMixin],
  props: {
    agents: {
      type: Array,
      default: () => [],
    },
  },
  computed: {
    users() {
      return this.agents.slice(0, 5).map(agent => ({
        id: agent.id,
        avatar: agent.avatar_url,
        name: agent.name,
      }));
    },
    title() {
      if (this.agents.length !== 0 && window.chatwootWebChannel.disableAgentNameWidget) {
        return 'Customer Service Agents Available';
      }
      else {
        return this.getAvailableAgentsText(this.agents);
      }
    },
  },
};
</script>
