json.payload do
  json.array! @inbox_members do |inbox_member|
    json.id inbox_member.user.id
    json.name inbox_member.user.available_name
    json.avatar_url inbox_member.user.avatar_url
    json.availability_status inbox_member.user.availability_status
    json.sip_target inbox_member.user.sip_target
    json.sip_server inbox_member.user.sip_server
    json.sip_display_name inbox_member.user.sip_display_name
  end
end
