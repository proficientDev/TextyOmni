class Signalwire::SendOnSignalwireService < Base::SendOnChannelService
  private

  def channel_class
    Channel::SignalwireSms
  end

  def perform_reply
    signalwire_message = client.messages.create(message_params)
    message.update!(source_id: signalwire_message.sid)
  end

  def message_params
    params = {
      body: message.content,
      from: channel.phone_number,
      to: contact_inbox.source_id
    }
    params
  end

  def inbox
    @inbox ||= message.inbox
  end

  def channel
    @channel ||= inbox.channel
  end

  def outgoing_message?
    message.outgoing? || message.template?
  end

  def client
    ::Signalwire::REST::Client.new(channel.account_sid, channel.auth_token, signalwire_space_url: channel.space_url)
  end
end
