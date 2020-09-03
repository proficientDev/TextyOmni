class Api::V1::Accounts::Channels::SignalwireChannelsController < Api::V1::Accounts::BaseController
  protect_from_forgery except: :create
  before_action :authorize_request

  def create
    ActiveRecord::Base.transaction do
      authenticate_signal_wire
      build_inbox
      setup_webhooks if @signal_wire_channel.sms?
      render json: @inbox
    rescue ::Twilio::REST::SignalwireError => e
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
      permitted_params[:account_sid],
      permitted_params[:auth_token],
      signalwire_space_url: permitted_params[:space_url]
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
    params.require(:signalwire_channel).permit(
      :account_id, :phone_number, :account_sid, :space_url, :phone_number, :auth_token, :name, :medium
    )
  end
end
