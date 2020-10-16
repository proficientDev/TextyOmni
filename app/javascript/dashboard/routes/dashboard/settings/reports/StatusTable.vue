<template>
<div style="display: contents">
  <tr v-for="(agent, index) in agentList" :key="agent.id">
    <table>
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
            {{ statusTime[index] }}
          </span>
        </td>
      </tr>
      <tr>
        <td class="colspan-2">abcde</td>
      </tr>
    </table>
  </tr>
</div>
</template>
<script>
export default {
  props: {
    agentList: {
      type: Array,
      default: []
    },
    statusTime: {
      type: Array,
      default: []
    },
  },
  mounted() {
    console.log(this.agentList);
  },
}
</script>