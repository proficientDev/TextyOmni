json.payload do
  json.array! @codes do |code|
    json.id code.id
    json.title code.title
    json.description code.description
  end
end
