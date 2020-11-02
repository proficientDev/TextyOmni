class Api::V1::Widget::ConversationsController < Api::V1::Widget::BaseController
  include Events::Types

  protect_from_forgery with: :null_session
  
  def index
    @conversation = conversation
  end

  def update_last_seen
    head :ok && return if conversation.nil?

    conversation.contact_last_seen_at = DateTime.now.utc
    conversation.save!
    head :ok
  end

  def transcript
    if permitted_params[:email].present? && conversation.present?
      ConversationReplyMailer.conversation_transcript(
        conversation,
        permitted_params[:email]
      )&.deliver_later
    end
    head :ok
  end

  def toggle_typing
    head :ok && return if conversation.nil?

    case permitted_params[:typing_status]
    when 'on'
      trigger_typing_event(CONVERSATION_TYPING_ON)
    when 'off'
      trigger_typing_event(CONVERSATION_TYPING_OFF)
    end

    head :ok
  end
  
  def call_request
  	@conversation = ::Conversation.create!(conversation_params) if conversation.nil?
  	@message = conversation.messages.new(message_params)
  	@message.save
  end

  private
  
  delegate :contact, :account, to: :conversation
  delegate :inbox, to: :message

  def trigger_typing_event(event)
    Rails.configuration.dispatcher.dispatch(event, Time.zone.now, conversation: conversation, user: @contact)
  end

  def permitted_params
    params.permit(:id, :typing_status, :website_token, :email)
  end
  
  def message_params
  	content = I18n.t('conversations.templates.call_options',
  										account_name: account.name)
  	
    {
      account_id: conversation.account_id,
      # sender: @contact,
      # content: permitted_params[:message][:content],
      content_attributes: call_request_attributes,
      inbox_id: conversation.inbox_id,
      # echo_id: permitted_params[:message][:echo_id],
      message_type: :template,
      content: content,
      content_type: :input_select
    }
  end

  def conversation_params
    {
      account_id: inbox.account_id,
      inbox_id: inbox.id,
      contact_id: @contact.id,
      contact_inbox_id: @contact_inbox.id,
      additional_attributes: {
        browser: browser_params,
        referer: permitted_params[:message][:referer_url],
        initiated_at: timestamp_params
      }
    }
  end
  
  def inbox
    @inbox ||= ::Inbox.find_by(id: auth_token_params[:inbox_id])
  end
  
  def permitted_params
    params.permit(:id, :before, :website_token, message: [:content, :referer_url, :timestamp, :echo_id])
  end
  
  def timestamp_params
    {
      timestamp: permitted_params[:message][:timestamp]
    }
  end
  
  def call_request_attributes
  	option1 = "Call back"
  	option2 = "Voice chat now"
  	
  	{
  		items: [
            { title: option1, value: option1 },
            { title: option2, value: option2 }
        ]
  	}
  end
end
