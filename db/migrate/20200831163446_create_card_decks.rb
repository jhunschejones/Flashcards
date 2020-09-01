class CreateCardDecks < ActiveRecord::Migration[6.0]
  def change
    create_table :card_decks do |t|
      t.references :card, null: false, foreign_key: { on_delete: :cascade }
      t.references :deck, null: false, foreign_key: { on_delete: :cascade }
      t.text :status
      t.datetime :next_review_at
      t.integer :position

      t.timestamps
    end

    add_index :card_decks, [:card_id, :deck_id], unique: true
  end
end
