class CreateDecks < ActiveRecord::Migration[6.0]
  def change
    create_table :decks do |t|
      t.text :name, null: false
      t.string :start_with
      t.boolean :is_randomized, default: false

      t.timestamps
    end
  end
end
