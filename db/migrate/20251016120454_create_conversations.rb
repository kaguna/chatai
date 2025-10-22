class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.string :title
      t.string :session_id

      t.timestamps
    end

    add_index :conversations, :session_id, unique: true
  end
end
