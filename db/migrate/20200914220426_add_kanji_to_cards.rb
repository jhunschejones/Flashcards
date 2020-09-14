class AddKanjiToCards < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :kanji, :string
  end
end
