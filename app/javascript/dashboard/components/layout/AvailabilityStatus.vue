<template>
  <div class="status">
    <div class="status-view">
      <div
        :class="
          `status-view--badge status-view--badge__${currentUserAvailabilityStatusFilter()}`
        "
      />

      <div class="status-view--title">
        {{ currentUserAvailabilityStatus }}
      </div>
    </div>

    <div class="status-change">
      <button class="status-change--change-button" @click="openStatusMenu">
        {{ $t('SIDEBAR_ITEMS.CHANGE_AVAILABILITY_STATUS.LABEL') }}
      </button>
    </div>
    <woot-modal :show.sync="isStatusMenuOpened" :on-close="closeStatusMenu">
      <woot-modal-header
        :header-title="$t('SIDEBAR_ITEMS.CHANGE_AVAILABILITY_STATUS.LABEL')"
      />
      <form class="row medium-8" @submit.prevent="changeAvailabilityStatus()">
        <div class="medium-12 columns">
          <label>
            {{ $t('SIDEBAR_ITEMS.CHANGE_AVAILABILITY_STATUS.LABEL_TXT') }}
            <select v-model="availability">
              <option
                v-for="status in availabilityStatuses"
                :key="status.key"
                class="text-capitalize"
                :value="status.value"
              >
                {{ status.label }}
              </option>
            </select>
          </label>
        </div>
        <div class="medium-12 modal-footer">
          <div class="medium-6 columns">
            <woot-submit-button
              :button-text="$t('SIDEBAR_ITEMS.CHANGE_AVAILABILITY_STATUS.MODAL.SUBMIT')"
              :loading="isUpdating"
            />
            <button class="button clear" @click.prevent="closeStatusMenu">
              {{ $t('SIDEBAR_ITEMS.CHANGE_AVAILABILITY_STATUS.MODAL.CANCEL_BUTTON') }}
            </button>
          </div>
        </div>
      </form>
    </woot-modal>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import { mixin as clickaway } from 'vue-clickaway';

export default {
  mixins: [clickaway],

  data() {
    return {
      isStatusMenuOpened: false,
      isUpdating: false,
      availability: 'online',
    };
  },

  computed: {
    ...mapGetters({
      currentUser: 'getCurrentUser',
      currentAvailabilityStatus: 'getCurrentUserAvailabilityStatus',
      records: 'getCodes',
    }),
    currentUserAvailabilityStatus() {
      return this.currentUser.availability_status;
    },
    currentUserBusyCodes() {
      return this.records;
    },
    availabilityStatuses() {
      const originStatues = this.$t('PROFILE_SETTINGS.FORM.AVAILABILITY.STATUSES_LIST').map(
        status => ({
          ...status,
        })
      );
      const customStatues = this.records.map(
        status => ({
          value: status.title,
          label: status.title,
        })
      );
      const statuses = [...originStatues, ...customStatues];
      return statuses;
    },
  },

  watch: {
    currentAvailabilityStatus(newStatus, oldStatus) {
      if (newStatus !== oldStatus) {
        this.availability = newStatus;
      }
    },
  },
  
  methods: {
    openStatusMenu() {
      this.isStatusMenuOpened = true;
    },
    closeStatusMenu() {
      this.isStatusMenuOpened = false;
    },
    changeAvailabilityStatus() {
      let availability = this.availability;
      console.log(availability);
      if (this.isUpdating) {
        return;
      }

      this.isUpdating = true;

      this.$store
        .dispatch('updateAvailability', {
          availability,
        })
        .finally(() => {
          this.isUpdating = false;
          this.isStatusMenuOpened = false;
        });
    },
    currentUserAvailabilityStatusFilter() {
      const arr = ['online', 'offline', 'busy'];
      
      return arr.includes(this.currentUserAvailabilityStatus) ? this.currentUserAvailabilityStatus : 'busy-codes';
    },
  },
};
</script>

<style lang="scss">
@import '~dashboard/assets/scss/variables';

.status {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  padding: $space-micro $space-smaller;
}

.status-view {
  display: flex;
  align-items: baseline;

  & &--badge {
    width: $space-one;
    height: $space-one;
    border-radius: 50%;

    &__online {
      background: $success-color;
    }

    &__offline {
      background: $color-gray;
    }

    &__busy {
      background: $warning-color;
    }
    
    &__busy-codes {
      background: $alert-color
    }
  }

  & &--title {
    color: $color-gray;
    font-size: $font-size-small;
    font-weight: $font-weight-medium;
    margin-left: $space-small;

    &:first-letter {
      text-transform: capitalize;
    }
  }
}

.status-change {
  .dropdown-pane {
    top: -130px;
  }

  .status-items {
    display: flex;
    align-items: baseline;
  }

  & &--change-button {
    color: $color-gray;
    font-size: $font-size-small;
    border-bottom: 1px solid $color-gray;
    cursor: pointer;

    &:hover {
      border-bottom: none;
    }
  }

  & &--dropdown-button {
    font-weight: $font-weight-normal;
    font-size: $font-size-small;
    padding: $space-small $space-one;
    text-align: left;
    width: 100%;
  }
}

.status-badge {
  width: $space-one;
  height: $space-one;
  border-radius: 50%;

  &__online {
    background: $success-color;
  }

  &__offline {
    background: $color-gray;
  }

  &__busy {
    background: $warning-color;
  }
}
</style>
