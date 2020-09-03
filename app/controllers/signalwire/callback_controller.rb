class Signalwire::CallbackController < ApplicationController
  # protect_from_forgery with: :null_session
  protect_from_forgery except: :create

  def create
    # {
    # "SmsSid"=>"6487c887-4c02-43d5-9b3c-a9fb31b0ee80",
    # "From"=>"+13305104190",
    # "AccountSid"=>"ce607000-9d51-4699-85d3-f628a36da245",
    # "MessageSid"=>"6487c887-4c02-43d5-9b3c-a9fb31b0ee80",
    # "To"=>"+13305104190",
    # "Body"=>"You've received a 12-character message. Upgrade your Trial account to view this message."
    # }
    # permitted_params example
    # ToDo: remove
    ::Signalwire::IncomingMessageService.new(params: permitted_params).perform

    head :no_content
  end

  private

  def permitted_params
    params.permit(
      :ApiVersion,
      :SmsSid,
      :From,
      :ToState,
      :ToZip,
      :AccountSid,
      :MessageSid,
      :FromCountry,
      :ToCity,
      :FromCity,
      :To,
      :FromZip,
      :Body,
      :ToCountry,
      :FromState,
      :MediaUrl0,
      :MediaContentType0
    )
  end
end
