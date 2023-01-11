class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :slack_id, null: false
      t.string :name, null: false
      t.string :access_token, null: false
      t.string :bot_user_id, null: false

      t.timestamps
    end
  end
end
