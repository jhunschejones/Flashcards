class RenameCardJapaneseKanaColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column :cards, :japanese, :kana
  end
end
