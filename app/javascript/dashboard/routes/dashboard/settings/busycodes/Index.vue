<template>
  <div class="column content-box">
    <button
      class="button nice icon success button--fixed-right-top"
      @click="openAddPopup"
    >
      <i class="icon ion-android-add-circle"></i>
      {{ $t('CODE_MGMT.HEADER_BTN_TXT') }}
    </button>
    <div class="row">
      <div class="small-8 columns">
        <p
          v-if="!uiFlags.isFetching && !records.length"
          class="no-items-error-message"
        >
          {{ $t('CODE_MGMT.LIST.404') }}
        </p>
        <woot-loading-state
          v-if="uiFlags.isFetching"
          :message="$t('CODE_MGMT.LOADING')"
        />
        <table v-if="!uiFlags.isFetching && records.length" class="woot-table">
          <thead>
            <th
              v-for="thHeader in $t('CODE_MGMT.LIST.TABLE_HEADER')"
              :key="thHeader"
            >
              {{ thHeader }}
            </th>
          </thead>
          <tbody>
            <tr v-for="(code, index) in records" :key="code.title">
              <td>{{ code.title }}</td>
              <td>{{ code.description }}</td>
              <td>
                <div class="code-color--container">
                  <span
                    class="code-color--display"
                    :style="{ backgroundColor: code.color }"
                  />
                  {{ code.color }}
                </div>
              </td>
              <td class="button-wrapper">
                <woot-submit-button
                  :button-text="$t('CODE_MGMT.FORM.EDIT')"
                  icon-class="ion-edit"
                  button-class="link hollow grey-btn"
                  @click="openEditPopup(code)"
                />

                <woot-submit-button
                  :button-text="$t('CODE_MGMT.FORM.DELETE')"
                  :loading="loading[code.id]"
                  icon-class="ion-close-circled"
                  button-class="link hollow grey-btn"
                  @click="openDeletePopup(code, index)"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="small-4 columns">
        <span v-html="$t('CODE_MGMT.SIDEBAR_TXT')"></span>
      </div>
    </div>

    <add-code
      v-if="showAddPopup"
      :show.sync="showAddPopup"
      :on-close="hideAddPopup"
    />

    <edit-code
      v-if="showEditPopup"
      :show.sync="showEditPopup"
      :selected-response="selectedResponse"
      :on-close="hideEditPopup"
    />

    <woot-delete-modal
      :show.sync="showDeleteConfirmationPopup"
      :on-close="closeDeletePopup"
      :on-confirm="confirmDeletion"
      :title="$t('CODE_MGMT.DELETE.CONFIRM.TITLE')"
      :message="deleteMessage"
      :confirm-text="deleteConfirmText"
      :reject-text="deleteRejectText"
    />
  </div>
</template>
<script>
import { mapGetters } from 'vuex';

import AddCode from './AddCode';
import EditCode from './EditCode';
import alertMixin from 'shared/mixins/alertMixin';

export default {
  components: {
    AddCode,
    EditCode,
  },
  mixins: [alertMixin],
  data() {
    return {
      loading: {},
      showAddPopup: false,
      showEditPopup: false,
      showDeleteConfirmationPopup: false,
      selectedResponse: {},
    };
  },
  computed: {
    ...mapGetters({
      records: 'codes/getCodes',
      uiFlags: 'codes/getUIFlags',
    }),
    // Delete Modal
    deleteConfirmText() {
      return `${this.$t('CODE_MGMT.DELETE.CONFIRM.YES')} ${
        this.selectedResponse.title
      }`;
    },
    deleteRejectText() {
      return `${this.$t('CODE_MGMT.DELETE.CONFIRM.NO')} ${
        this.selectedResponse.title
      }`;
    },
    deleteMessage() {
      return `${this.$t('CODE_MGMT.DELETE.CONFIRM.MESSAGE')} ${
        this.selectedResponse.title
      } ?`;
    },
  },
  watch: {
    records: {
      handler(records) {
        console.log('records', records);
      },
      deep: true
    }
  },
  mounted() {
    this.$store.dispatch('codes/get');
  },
  methods: {
    openAddPopup() {
      this.showAddPopup = true;
    },
    hideAddPopup() {
      this.showAddPopup = false;
    },

    openEditPopup(response) {
      this.showEditPopup = true;
      this.selectedResponse = response;
    },
    hideEditPopup() {
      this.showEditPopup = false;
    },

    openDeletePopup(response) {
      this.showDeleteConfirmationPopup = true;
      this.selectedResponse = response;
    },
    closeDeletePopup() {
      this.showDeleteConfirmationPopup = false;
    },

    confirmDeletion() {
      this.loading[this.selectedResponse.id] = true;
      this.closeDeletePopup();
      this.deletecode(this.selectedResponse.id);
    },
    deletecode(id) {
      this.$store
        .dispatch('codes/delete', id)
        .then(() => {
          this.showAlert(this.$t('CODE_MGMT.DELETE.API.SUCCESS_MESSAGE'));
        })
        .catch(() => {
          this.showAlert(this.$t('CODE_MGMT.DELETE.API.ERROR_MESSAGE'));
        })
        .finally(() => {
          this.loading[this.selectedResponse.id] = false;
        });
    },
  },
};
</script>

<style scoped lang="scss">
@import '~dashboard/assets/scss/variables';

.code-color--container {
  display: flex;
  align-items: center;
}

.code-color--display {
  border-radius: $space-smaller;
  height: $space-normal;
  margin-right: $space-smaller;
  width: $space-normal;
}
</style>
