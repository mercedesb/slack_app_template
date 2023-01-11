# frozen_string_literal: true

require "rails_helper"

RSpec.describe SlackChannelClient do
  subject(:client) { described_class.new('1', 'C1234567890') }

  before do
    Team.create(slack_id: '1', name: 'test team', bot_user_id: 'W369E3ABC', access_token: 'token')
    allow(HTTParty).to receive(:get)
    allow(HTTParty).to receive(:post)
    allow(ENV).to receive(:fetch).with('NOTIFICATION_BASE_URL').and_return('base url')
  end

  describe "#members" do
    let(:response_without_cursor) do
      {
        "ok": true,
        "members": %w[
          U045ADBEC
          U074G5BGW
          W369E3ABC
        ],
        "response_metadata": {
          "next_cursor": ""
        }
      }.with_indifferent_access
    end

    describe "when response is paginated" do
      let(:expected_members) do
        response_with_cursor['members'] + response_without_cursor['members']
      end
      let(:response_with_cursor) do
        {
          "ok": true,
          "members": %w[
            U023BECGF
            U061F7AUR
            W012A3CDE
          ],
          "response_metadata": {
            "next_cursor": "e3VzZXJfaWQ6IFcxMjM0NTY3fQ=="
          }
        }.with_indifferent_access
      end

      before do
        allow(HTTParty).to receive(:get).and_return(response_with_cursor, response_without_cursor)
      end

      it "returns the members from the response" do
        expect(client.members).to eq(expected_members)
      end
    end

    describe "when response is not paginated" do
      let(:expected_members) do
        response_without_cursor['members']
      end
      before do
        allow(HTTParty).to receive(:get).and_return(response_without_cursor)
      end

      it "returns the members from the response" do
        expect(client.members).to eq(expected_members)
      end
    end

    describe "when an error occurs" do
      let(:response_with_error) do
        {
          "ok": false,
          "error": "invalid_cursor"
        }.with_indifferent_access
      end

      before do
        allow(Rails.logger).to receive(:error)
        allow(HTTParty).to receive(:get).and_return(response_with_error)
      end

      it "returns an empty array" do
        expect(client.members).to eq([])
      end

      it "logs an error" do
        expect(Rails.logger).to receive(:error).with(response_with_error['error'])
        client.members
      end
    end
  end

  describe "#user_info" do
    let(:success_response) do
      {
        "ok": true,
        "user": {
          "id": "W012A3CDE",
          "team_id": "T012AB3C4",
          "name": "spengler",
          "deleted": false,
          "color": "9f69e7",
          "real_name": "Egon Spengler",
          "tz": "America/Los_Angeles",
          "tz_label": "Pacific Daylight Time",
          "tz_offset": -25_200,
          "profile": {
            "avatar_hash": "ge3b51ca72de",
            "status_text": "Print is dead",
            "status_emoji": ":books:",
            "real_name": "Egon Spengler",
            "display_name": "spengler",
            "real_name_normalized": "Egon Spengler",
            "display_name_normalized": "spengler",
            "email": "spengler@ghostbusters.example.com",
            "team": "T012AB3C4"
          },
          "is_admin": true,
          "is_owner": false,
          "is_primary_owner": false,
          "is_restricted": false,
          "is_ultra_restricted": false,
          "is_bot": false,
          "updated": 1_502_138_686,
          "is_app_user": false,
          "has_2fa": false
        }
      }.with_indifferent_access
    end

    before do
      allow(HTTParty).to receive(:get).and_return(success_response)
    end

    it "returns the user response" do
      expect(client.user_info('W1234567890')).to eq(success_response['user'])
    end

    describe "when an error occurs" do
      let(:response_with_error) do
        {
          "ok": false,
          "error": "user_not_found"
        }.with_indifferent_access
      end

      before do
        allow(Rails.logger).to receive(:error)
        allow(HTTParty).to receive(:get).and_return(response_with_error)
      end

      it "returns false" do
        expect(client.user_info('W1234567890')).to eq({})
      end

      it "logs an error" do
        expect(Rails.logger).to receive(:error).with(response_with_error['error'])
        client.user_info('W1234567890')
      end
    end
  end

  describe "#message_and_subsequent_messages" do
    let(:timestamp) { "1512085950.000216" }
    let(:response_without_cursor) do
      {
        "ok": true,
        "messages": [
          {
            "type": "message",
            "user": "U012AB3CDE",
            "text": "Never let a bad day make you feel bad about yourself.",
            "ts": "1512085950.000216"
          }
        ],
        "response_metadata": {
          "next_cursor": ""
        }
      }.with_indifferent_access
    end

    describe "when response is paginated" do
      let(:expected_messages) do
        response_with_cursor['messages'] + response_without_cursor['messages']
      end
      let(:response_with_cursor) do
        {
          "ok": true,
          "messages": [
            {
              "type": "message",
              "user": "U012AB3CDE",
              "text": "Friend something better than chocolate ice cream. Maybe friend somebody you give up last cookie for.",
              "ts": "1512085950.000216"
            },
            {
              "type": "message",
              "user": "U061F7AUR",
              "text": "You’d be a grouch, too, if you lived in a trash can!",
              "ts": "1512104434.000490"
            }
          ],
          "response_metadata": {
            "next_cursor": "e3VzZXJfaWQ6IFcxMjM0NTY3fQ=="
          }
        }.with_indifferent_access
      end

      before do
        allow(HTTParty).to receive(:get).and_return(response_with_cursor, response_without_cursor)
      end

      it "returns the messages from the response" do
        expect(client.message_and_subsequent_messages(timestamp)).to eq(expected_messages)
      end
    end

    describe "when response is not paginated" do
      let(:expected_messages) do
        response_without_cursor['messages']
      end
      before do
        allow(HTTParty).to receive(:get).and_return(response_without_cursor)
      end

      it "returns the messages from the response" do
        expect(client.message_and_subsequent_messages(timestamp)).to eq(expected_messages)
      end
    end

    describe "when an error occurs" do
      let(:response_with_error) do
        {
          "ok": false,
          "error": "channel_not_found"
        }.with_indifferent_access
      end

      before do
        allow(Rails.logger).to receive(:error)
        allow(HTTParty).to receive(:get).and_return(response_with_error)
      end

      it "returns an empty array" do
        expect(client.message_and_subsequent_messages(timestamp)).to eq([])
      end

      it "logs an error" do
        expect(Rails.logger).to receive(:error).with(response_with_error['error'])
        client.message_and_subsequent_messages(timestamp)
      end
    end
  end
end
