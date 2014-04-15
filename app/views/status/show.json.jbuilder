json.status @status

json.services @pings do |ping|
  json.name        ping.service
  json.status      ping.state
  json.description ping.description

  if !ping.unknown?
    json.last_seen ping.last_seen.iso8601
  else
    json.last_seen "unknown"
  end
end
