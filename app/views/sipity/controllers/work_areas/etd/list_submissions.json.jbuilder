json.links do
  json.self Sipity::Conversions::ConvertToJsonApiLink.call(:self, request: request, pager: view_object.works)
  json.first Sipity::Conversions::ConvertToJsonApiLink.call(:first, request: request, pager: view_object.works)
  json.prev Sipity::Conversions::ConvertToJsonApiLink.call(:prev, request: request, pager: view_object.works)
  json.next Sipity::Conversions::ConvertToJsonApiLink.call(:next, request: request, pager: view_object.works)
  json.last Sipity::Conversions::ConvertToJsonApiLink.call(:last, request: request, pager: view_object.works)
end

json.data do
  json.array!(view_object.as_json)
end
