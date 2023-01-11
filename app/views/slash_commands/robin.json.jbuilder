json.response_type "in_channel"
json.blocks @blocks do |block|
  json.partial! '_shared/slack_block', block:
end
