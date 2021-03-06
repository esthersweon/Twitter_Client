class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.string :screen_name, null: false, unique: true
    	t.string :twitter_user_id, null: false, unique: true

    	t.timestamps
    end

    add_index :users, :twitter_user_id
  end
end