class Team < ApplicationRecord
  validates :name, :slack_id, :bot_user_id, :access_token, presence: true

  def access_token=(value)
    super(crypt.encrypt_and_sign(value))
  end

  def access_token
    if super.present?
      crypt.decrypt_and_verify(super)
    else
      ""
    end
  end

  private

  def crypt
    @crypt ||= ActiveSupport::MessageEncryptor.new(Rails.application.credentials.secret_key_base[0..31])
  end
end
