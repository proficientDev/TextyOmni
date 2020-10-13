import SettingsContent from '../Wrapper';
import AgentHome from './Index';
import Histories from './Histories';
import { frontendURL } from '../../../../helper/URLHelper';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/agents'),
      component: SettingsContent,
      // props: {
      //   headerTitle: 'AGENT_MGMT.HEADER',
      //   icon: 'ion-person-stalker',
      //   showNewButton: false,
      // },
      props: params => {
        const showBackButton = params.name !== 'agent_list';
        return {
          headerTitle: 'AGENT_MGMT.VIEW_TRACKS.HEADER',
          icon: 'ion-person-stalker',
          newButtonRoutes: ['agent_list'],
          showBackButton,
          showNewButton: false,
        };
      },
      children: [
        {
          path: '',
          name: 'agents_wrapper',
          redirect: 'list',
        },
        {
          path: 'list',
          name: 'agent_list',
          component: AgentHome,
          roles: ['administrator'],
        },
        {
          path: ':agent_id/histories',
          name: 'agent_histories',
          component: Histories,
          roles: ['administrator'],
        },
      ],
    },
  ],
};
