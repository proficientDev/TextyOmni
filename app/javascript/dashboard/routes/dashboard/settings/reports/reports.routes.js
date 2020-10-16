import Index from './Index';
import SettingsContent from '../Wrapper';
import AgentStatus from './AgentStatus';
import { frontendURL } from '../../../../helper/URLHelper';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/reports'),
      component: SettingsContent,
      // props: {
      //   headerTitle: 'REPORT.HEADER',
      //   headerButtonText: 'REPORT.HEADER_BTN_TXT',
      //   icon: 'ion-arrow-graph-up-right',
      // },
      props: params => {
        const showBackButton = params.name !== 'settings_account_reports';
        return {
          headerTitle: 'REPORT.HEADER',
          headerButtonText: 'REPORT.HEADER_BTN_TXT',
          icon: 'ion-arrow-graph-up-right',
          showBackButton,
          showNewButton: false,
        };
      },
      children: [
        {
          path: '',
          name: 'settings_account_reports',
          roles: ['administrator'],
          component: Index,
        },
        {
          path: 'status',
          name: 'agent_status_conversations',
          component: AgentStatus,
          roles: ['administrator'],
        },
      ],
    },
  ],
};
