class Api::V1::Accounts::AgentHistoriesController < ApplicationController
  before_action :fetch_agent_histories, only: [:show]
  def index
    @agent_histories = agent_histories
  end
  
  def show
    Rails.logger.info "--------------USER: #{@agent_histories}"
    # return @agent_histories
    render partial: 'api/v1/models/agent_histories.json.jbuilder', locals: { resource: @agent_histories }
  end
  
  private

  def fetch_agent_histories
    @agent_histories = Current.account.users.find(params[:id]).availability_statuses
  end
end
