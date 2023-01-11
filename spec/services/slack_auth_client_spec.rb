require "rails_helper"

RSpec.describe SlackAuthClient do
  subject(:client) { described_class.new }

  before do
    allow(HTTParty).to receive(:post)
    allow(ENV).to receive(:fetch).with('NOTIFICATION_BASE_URL').and_return('base url')
    allow(ENV).to receive(:fetch).with('CLIENT_ID').and_return('id')
    allow(ENV).to receive(:fetch).with('CLIENT_SECRET').and_return('secret')
  end

  describe "#oauth_access" do
    let(:success_response) do
      {
        "ok": true,
        "access_token": "xoxb-17653672481-19874698323-pdFZKVeTuE8sk7oOcBrzbqgy",
        "token_type": "bot",
        "scope": "commands,incoming-webhook",
        "bot_user_id": "U0KRQLJ9H",
        "app_id": "A0KRD7HC3",
        "team": {
          "name": "Slack Softball Team",
          "id": "T9TK3CUKW"
        },
        "enterprise": {
          "name": "slack-sports",
          "id": "E12345678"
        },
        "authed_user": {
          "id": "U1234",
          "scope": "chat:write",
          "access_token": "xoxp-1234",
          "token_type": "user"
        }
      }.with_indifferent_access
    end

    before do
      allow(HTTParty).to receive(:post).and_return(success_response)
    end

    it "returns the full response" do
      expect(client.oauth_access('code')).to eq(success_response)
    end

    describe "when an error occurs" do
      let(:response_with_error) do
        {
          "ok": false,
          "error": "invalid_client_id"
        }.with_indifferent_access
      end

      before do
        allow(Rails.logger).to receive(:error)
        allow(HTTParty).to receive(:post).and_return(response_with_error)
      end

      it "returns an empty hash" do
        expect(client.oauth_access('code')).to eq({})
      end

      it "logs an error" do
        expect(Rails.logger).to receive(:error).with(response_with_error['error'])
        client.oauth_access('code')
      end
    end
  end
end
