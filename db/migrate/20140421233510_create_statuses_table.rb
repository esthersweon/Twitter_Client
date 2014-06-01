class CreateStatusesTable < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :text, :limit => 140, null: :false
      t.string :twitter_status_id, null: :false, unique: true
      t.string :twitter_user_id, null: :false

      t.timestamps

    end
  end
end
