<template>
  <modal :show.sync="show" :on-close="onClose">
    <div class="column content-box">
      <woot-modal-header :header-title="pageTitle" />
      <form class="row medium-8" @submit.prevent="editAgent()">
        <div class="medium-12 columns">
          <label :class="{ error: $v.agentName.$error }">
            {{ $t('AGENT_MGMT.EDIT.FORM.NAME.LABEL') }}
            <input
              v-model.trim="agentName"
              type="text"
              :placeholder="$t('AGENT_MGMT.EDIT.FORM.NAME.PLACEHOLDER')"
              @input="$v.agentName.$touch"
            />
          </label>
        </div>

        <div class="medium-12 columns">
          <label :class="{ error: $v.agentType.$error }">
            {{ $t('AGENT_MGMT.EDIT.FORM.AGENT_TYPE.LABEL') }}
            <select v-model="agentType">
              <option v-for="role in roles" :key="role.name" :value="role.name">
                {{ role.label }}
              </option>
            </select>
            <span v-if="$v.agentType.$error" class="message">
              {{ $t('AGENT_MGMT.EDIT.FORM.AGENT_TYPE.ERROR') }}
            </span>
          </label>
        </div>
        <div class="medium-12 columns">
          <label :class="{ error: $v.agentConversationLimits.$error }">
            {{ $t('AGENT_MGMT.EDIT.FORM.CONVERSATION_LIMITS.LABEL') }}
            <select v-model="agentConversationLimits">
              <option v-for="value in valuesOfLimit" :key="value" :value="value">
                {{ value }}
              </option>
            </select>
            <span v-if="$v.agentConversationLimits.$error" class="message">
              {{ $t('AGENT_MGMT.EDIT.FORM.CONVERSATION_LIMITS.ERROR') }}
            </span>
          </label>
        </div>
        <div class="medium-12 columns">
          <label>
            {{ $t('AGENT_MGMT.EDIT.FORM.AVAILABILITY_STATUS.LABEL') }}
            <select v-model="agentAvailabilityStatus == 'online' || agentAvailabilityStatus == 'offline' || agentAvailabilityStatus == 'busy' ? 'System Status' : agentAvailabilityStatus">
              <option v-for="value in availabilityStatuses" :key="value.value" :value="value.value">
                {{ value.label }}
              </option>
            </select>
          </label>
        </div>
        <div class="medium-12 modal-footer">
          <div class="medium-6 columns">
            <woot-submit-button
              :disabled="
                $v.agentType.$invalid ||
                  $v.agentName.$invalid ||
                  uiFlags.isUpdating
              "
              :button-text="$t('AGENT_MGMT.EDIT.FORM.SUBMIT')"
              :loading="uiFlags.isUpdating"
            />
            <button class="button clear" @click.prevent="onClose">
              {{ $t('AGENT_MGMT.EDIT.CANCEL_BUTTON_TEXT') }}
            </button>
          </div>
          <div class="medium-6 columns text-right">
            <button class="button clear" @click.prevent="resetPassword">
              <i class="ion-locked"></i>
              {{ $t('AGENT_MGMT.EDIT.PASSWORD_RESET.ADMIN_RESET_BUTTON') }}
            </button>
          </div>
        </div>
      </form>
    </div>
  </modal>
</template>

<script>
import { required, minLength } from 'vuelidate/lib/validators';
import { mapGetters } from 'vuex';
import WootSubmitButton from '../../../../components/buttons/FormSubmitButton';
import Modal from '../../../../components/Modal';
import Auth from '../../../../api/auth';

export default {
  components: {
    WootSubmitButton,
    Modal,
  },
  props: {
    id: {
      type: Number,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      default: '',
    },
    type: {
      type: String,
      default: '',
    },
    limits: {
      type: Number,
      default: 1,
    },
    availability: {
      type: String,
      default: '',
    },
    onClose: {
      type: Function,
      required: true,
    },
  },
  data() {
    return {
      roles: [
        {
          name: 'administrator',
          label: this.$t('AGENT_MGMT.AGENT_TYPES.ADMINISTRATOR'),
        },
        {
          name: 'agent',
          label: this.$t('AGENT_MGMT.AGENT_TYPES.AGENT'),
        },
      ],
      agentName: this.name,
      agentType: this.type,
      agentCredentials: {
        email: this.email,
      },
      show: true,
      agentConversationLimits: this.limits,
      valuesOfLimit: [1,2,3,4,5,6,7,8,9,10],
      agentAvailabilityStatus: this.availability,
    };
  },
  validations: {
    agentName: {
      required,
      minLength: minLength(4),
    },
    agentType: {
      required,
    },
    agentConversationLimits: {
      required,
    },
  },
  computed: {
    pageTitle() {
      return `${this.$t('AGENT_MGMT.EDIT.TITLE')} - ${this.name}`;
    },
    ...mapGetters({
      uiFlags: 'agents/getUIFlags',
      valuesOfAvailability: 'codes/getCodes',
    }),
    availabilityStatuses() {
      const originStatues = [{value: 'System Status', label: 'System Status'}];
      const customStatues = this.valuesOfAvailability.map(
        status => ({
          value: status.title,
          label: status.title,
        })
      );
      const statuses = [...originStatues, ...customStatues];
      return statuses;
    },
  },
  mounted() {
    this.$store.dispatch('codes/get').then(() => {console.log(this.agentAvailabilityStatus);});
  },
  methods: {
    showAlert(message) {
      bus.$emit('newToastMessage', message);
    },
    async editAgent() {
      try {
        await this.$store.dispatch('agents/update', {
          id: this.id,
          name: this.agentName,
          role: this.agentType,
          limits: this.agentConversationLimits,
          availability: this.agentAvailabilityStatus,
        });
        this.showAlert(this.$t('AGENT_MGMT.EDIT.API.SUCCESS_MESSAGE'));
        this.onClose();
      } catch (error) {
        this.showAlert(this.$t('AGENT_MGMT.EDIT.API.ERROR_MESSAGE'));
      }
    },
    async resetPassword() {
      try {
        await Auth.resetPassword(this.agentCredentials);
        this.showAlert(
          this.$t('AGENT_MGMT.EDIT.PASSWORD_RESET.ADMIN_SUCCESS_MESSAGE')
        );
      } catch (error) {
        this.showAlert(this.$t('AGENT_MGMT.EDIT.PASSWORD_RESET.ERROR_MESSAGE'));
      }
    },
  },
};
</script>
