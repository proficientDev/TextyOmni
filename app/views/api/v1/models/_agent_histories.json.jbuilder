json.array! @agent_histories do |agent_history|
  json.user_id agent_history.user_id
  json.availability agent_history.availability
  json.updated_at agent_history.updated_at
end