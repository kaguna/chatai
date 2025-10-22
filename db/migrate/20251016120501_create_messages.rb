class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.string :session_id
      t.string :role
      t.text :content
      t.references :conversation, null: false, foreign_key: true

      t.timestamps
    end

    add_index :messages, :session_id
    add_index :messages, :role
  end
end
