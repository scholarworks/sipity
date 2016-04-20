json.links do
  json.self request.url
end

json.data(view_object)
