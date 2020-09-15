class CreateCards < ActiveRecord::Migration[6.0]
  def change
    create_table :cards do |t|
      t.text :english, null: false
      t.text :kana, null: false
      t.text :kanji
      t.bigint :review_count, default: 0

      t.timestamps
    end

    add_index :cards, [:english, :japanese], unique: true
  end
end
