class ChangeKanjiToText < ActiveRecord::Migration[6.0]
  def change
    change_column :cards, :kanji, :text
  end
end
