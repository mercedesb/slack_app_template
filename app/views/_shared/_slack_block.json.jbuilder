case block[:type]
when 'header'
  json.partial! '_shared/slack_header', text: block[:text]
when 'section'
  json.partial! '_shared/slack_section', text: block[:text]
end
