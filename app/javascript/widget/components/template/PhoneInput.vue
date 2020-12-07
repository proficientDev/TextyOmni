<template>
  <div>
    <form
      v-if="!hasSubmitted"
      class="phone-input-group"
      @submit.prevent="onSubmit()"
    >
      <input
        v-model.trim="phone"
        class="form-input"
        :placeholder="$t('PHONE_PLACEHOLDER')"
        @keyup.enter="onSubmit"
      />
      <button
        class="button"
        :style="{ background: widgetColor, borderColor: widgetColor }"
      >
        <i v-if="!uiFlags.isUpdating" class="ion-ios-arrow-forward" />
        <spinner v-else />
      </button>
    </form>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import Spinner from 'shared/components/Spinner';

export default {
  components: {
    Spinner,
  },
  props: {
    messageId: {
      type: Number,
      required: true,
    },
    messageContentAttributes: {
      type: Object,
      default: () => {},
    },
  },
  data() {
    return {
      phone: '',
    };
  },
  computed: {
    ...mapGetters({
      uiFlags: 'message/getUIFlags',
      widgetColor: 'appConfig/getWidgetColor',
    }),
    hasSubmitted() {
      return (
        this.messageContentAttributes &&
        this.messageContentAttributes.submitted_phone
      );
    },
  },
  methods: {
    onSubmit() {
      this.$store.dispatch('message/update', {
        phone: this.phone,
        messageId: this.messageId,
      });
    },
  },
};
</script>

<style lang="scss" scoped>
@import '~widget/assets/scss/variables.scss';

.phone-input-group {
  display: flex;
  margin: $space-small 0;
  min-width: 200px;

  input {
    border-bottom-right-radius: 0;
    border-top-right-radius: 0;
    padding: $space-one;
    width: auto;

    &.error {
      border-color: $color-error;
    }
  }

  .button {
    border-bottom-left-radius: 0;
    border-top-left-radius: 0;
    font-size: $font-size-large;
    height: auto;
    margin-left: -1px;

    .spinner {
      display: block;
      padding: 0;
      height: auto;
      width: auto;
    }
  }
}
</style>
