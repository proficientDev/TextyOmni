class Api::V1::Accounts::Channels::SignalwireChannelsController < Api::V1::Accounts::BaseController
  before_action :authorize_request

  module Twilio::REST
    class SignalwireError < ::Twilio::REST::TwilioError
    end
  end

  def create
    ActiveRecord::Base.transaction do
      authenticate_signal_wire
      build_inbox
      setup_webhooks if @signal_wire_channel.sms?
    rescue Signalwire::REST::SignalwireError => e
      render_could_not_create_error(e.message)
    rescue StandardError => e
      render_could_not_create_error(e.message)
    end
  end

  private

  def authorize_request
    authorize ::Inbox
  end

  def authenticate_signal_wire
    client = Signalwire::REST::Client.new(
      permitted_params[:account_sid] || 'ce607000-9d51-4699-85d3-f628a36da245',
      permitted_params[:auth_token] || 'PT672ccf03259864f6910563ec9da1cbea282ce0e8a7bfed55',
      signalwire_space_url: permitted_params[:space_url] || 'chatwoot-integration.signalwire.com'
    )
    client.messages.list(limit: 1)
  end

  def setup_webhooks
    ::Signalwire::WebhookSetupService.new(inbox: @inbox).perform
  end

  def medium
    permitted_params[:medium]
  end

  def build_inbox
    @signal_wire_channel = Current.account.signalwire_sms.create!(
      account_sid: permitted_params[:account_sid],
      auth_token: permitted_params[:auth_token],
      phone_number: permitted_params[:phone_number],
      space_url: permitted_params[:space_url],
      medium: medium
    )
    @inbox = Current.account.inboxes.create(
      name: permitted_params[:name],
      channel: @signal_wire_channel
    )
  end

  def permitted_params
    params.require(:signal_wire_channel).permit(
      :account_id, :phone_number, :account_sid, :space_url, :phone_number, :auth_token, :name, :medium
    )
  end
end
