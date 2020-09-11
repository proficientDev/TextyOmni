class Signalwire::IncomingMessageService
  include ::FileTypeHelper

  pattr_initialize [:params!]

  def perform
    set_contact
    set_conversation
    @message = @conversation.messages.create(
      content: params[:Body],
      account_id: @inbox.account_id,
      inbox_id: @inbox.id,
      message_type: :incoming,
      sender: @contact,
      source_id: params[:SmsSid]
    )
    attach_files
  end

  private

  def signalwire_inbox
    @signalwire_inbox ||= ::Channel::SignalwireSms.find_by!(
      account_sid: params[:AccountSid],
      phone_number: params[:To]
    )
  end

  def inbox
    @inbox ||= signalwire_inbox.inbox
  end

  def account
    @account ||= inbox.account
  end

  def formatted_phone_number
    TelephoneNumber.parse(params[:From]).international_number
  end

  def set_contact
    contact_inbox = ::ContactBuilder.new(
      source_id: params[:From],
      inbox: inbox,
      contact_attributes: contact_attributes
    ).perform

    @contact_inbox = contact_inbox
    @contact = contact_inbox.contact
  end

  def conversation_params
    {
      account_id: @inbox.account_id,
      inbox_id: @inbox.id,
      contact_id: @contact.id,
      contact_inbox_id: @contact_inbox.id,
      additional_attributes: additional_attributes
    }
  end

  def set_conversation
    @conversation = @contact_inbox.conversations.first
    return if @conversation

    @conversation = ::Conversation.create!(conversation_params)
  end

  def contact_attributes
    {
      name: formatted_phone_number,
      phone_number: params[:From],
      additional_attributes: additional_attributes
    }
  end

  def additional_attributes
    if signalwire_inbox.sms?
      {
        from_zip_code: params[:FromZip],
        from_country: params[:FromCountry],
        from_state: params[:FromState]
      }
    else
      {}
    end
  end

  def attach_files
    return if params[:MediaUrl0].blank?

    file_resource = LocalResource.new(params[:MediaUrl0], params[:MediaContentType0])

    attachment = @message.attachments.new(
      account_id: @message.account_id,
      file_type: file_type(params[:MediaContentType0])
    )

    attachment.file.attach(
      io: file_resource.file,
      filename: file_resource.tmp_filename,
      content_type: file_resource.encoding
    )

    @message.save!
  rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED => e
    Rails.logger.info "invalid url #{file_url} : #{e.message}"
  end
end
