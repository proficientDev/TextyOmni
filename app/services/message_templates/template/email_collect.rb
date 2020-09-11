class MessageTemplates::Template::EmailCollect
  pattr_initialize [:conversation!]

  def perform
    ActiveRecord::Base.transaction do
      conversation.messages.create!(ways_to_reach_you_message_params)
      conversation.messages.create!(email_input_box_template_message_params)
      # conversation.messages.create!(phone_number_input_box_template_message_params)
  end
  rescue StandardError => e
    Raven.capture_exception(e)
    true
  end

  private

  delegate :contact, :account, to: :conversation
  delegate :inbox, to: :message

  def ways_to_reach_you_message_params
    content = I18n.t('conversations.templates.ways_to_reach_you_message_body',
                     account_name: account.name)

    {
      account_id: @conversation.account_id,
      inbox_id: @conversation.inbox_id,
      message_type: :template,
      content: content
    }
  end

  def email_input_box_template_message_params
    content = I18n.t('conversations.templates.email_input_box_message_body',
                     account_name: account.name)

    {
      account_id: @conversation.account_id,
      inbox_id: @conversation.inbox_id,
      message_type: :template,
      content_type: :input_email,
      content: content
    }
  end
  
  def phone_number_input_box_template_message_params
    content = I18n.t('conversations.templates.phone_number_input_box_message_body',
                     account_name: account.name)

    {
      account_id: @conversation.account_id,
      inbox_id: @conversation.inbox_id,
      message_type: :template,
      content_type: 'form',
      content_attributes: {
        "items": [
          # { "name": 'email', "placeholder": 'Please enter your email', "type": 'email', "label": 'Email' },
          # { "name": 'text_aread', "placeholder": 'Please enter text', "type": 'text_area', "label": 'Large Text' },
          { "name": 'name', "placeholder": 'Please enter your name', "type": 'text', "label": 'Name', "default": '' },
          { "name": 'phone_number', "placeholder": 'Please enter phone number', "type": 'text', "label": 'Phone Number', "default": '' }
        ]
      }, 
      content: content
    }
  end
end
