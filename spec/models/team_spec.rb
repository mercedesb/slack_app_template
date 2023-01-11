# frozen_string_literal: true

require "rails_helper"

RSpec.describe Team, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:groups) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slack_id) }
  end
end
