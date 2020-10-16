import SettingsContent from '../Wrapper';
import Index from './Index';
import { frontendURL } from '../../../../helper/URLHelper';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/busycodes'),
      component: SettingsContent,
      props: {
        headerTitle: 'CODE_MGMT.HEADER',
        icon: 'ion-flag',
        showNewButton: false,
      },
      children: [
        {
          path: '',
          name: 'codes_wrapper',
          roles: ['administrator'],
          redirect: 'list',
        },
        {
          path: 'list',
          name: 'codes_list',
          roles: ['administrator'],
          component: Index,
        },
      ],
    },
  ],
};
